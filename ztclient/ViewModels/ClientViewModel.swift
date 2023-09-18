//
//  ClientViewModel.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-15.
//

import Foundation

class ClientViewModel: ObservableObject {
    
    @Published var status: String = "..."
    @Published var description: String = "..."
    @Published var errorMessage: String = ""

    private let interactorFactory: InteractorFactory
    private var statusUpdateTimer: Timer?
    
    private let connectedText = "Connected"
    private let disconnectedText = "Disconnected"
    private let defaultConnectedMessage = "Your Internet is private"
    private let defaultDisconnectedMessage = "Your Internet is not private"
    
    init(interactorFactory: InteractorFactory = InteractorFactoryForProduction()) {
        self.interactorFactory = interactorFactory
    }
    
    /**
     start calling getStatus and repeat it every 5s
     */
    func refresh() {
        statusUpdateTimer?.invalidate()
        statusUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task.detached {
                await self.getStatus()
            }
        }
    }
    
    /**
     pause the timer to call getStatus, for example when app goes to background
     */
    func pause() {
        statusUpdateTimer?.invalidate()
        statusUpdateTimer = nil
    }
    
    private func getStatus() async {
        let getInteractor = interactorFactory.makeGetConnectionStatus()
        do {
            switch try await getInteractor.get() {
            case .success(let response):
                await MainActor.run {
                    switch response.status {
                    case .success:
                        if let data = response.data {
                            switch data.daemon_status {
                            case .connected:
                                self.status = connectedText
                                self.description = defaultConnectedMessage
                                self.errorMessage = ""
                            case .disconnected:
                                self.status = disconnectedText
                                self.description = defaultDisconnectedMessage
                                if let message = data.message {
                                    self.errorMessage = message
                                }
                            }
                        }
                    case .error:
                        self.status = disconnectedText
                        self.description = defaultDisconnectedMessage
                        if let message = response.message {
                            self.errorMessage = message
                        }
                    }
                }
            case .failure(let error):
                await MainActor.run {
                    self.status = disconnectedText
                    self.description = defaultDisconnectedMessage
                    if let socketApiError = error as? SocketApiError {
                        switch socketApiError {
                        case .socketCreationFailure:
                            self.errorMessage = "Failed in creating the Socket"
                        case .socketConnectionFailure:
                            self.errorMessage = "Failed in connecting to the Socket"
                        case .serializationFailure(let serializationError):
                            self.errorMessage = "Failed in serializing the data to the Socket. \(serializationError.localizedDescription)"
                        }
                    }
                }
            }
            
        } catch let error {
            print("Getting error: \(error)")
        }
    }
    
    func getAuthToken() async {
        let authInteractor = interactorFactory.makeGetAuthTokenInteractor()
        do {
            switch try await authInteractor.get() {
            case .success(let response):
                await MainActor.run {
//                    self.token = response.status.rawValue
                }
            case .failure(let networkApiError):
                await MainActor.run {
//                    token = networkApiError.localizedDescription
                }
            }
            
        } catch let error {
            print("Getting error: \(error)")
        }
    }
}

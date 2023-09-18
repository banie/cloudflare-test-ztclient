//
//  ClientViewModel.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-15.
//

import Foundation

struct CachedAuthToken {
    let token: Int
    let expiry: Double
    
    var isExpired: Bool {
        Date().timeIntervalSince1970 > expiry
    }
}

class ClientViewModel: ObservableObject {
    
    @Published var status: String = "..."
    @Published var description: String = "..."
    @Published var errorMessage: String = ""

    private let interactorFactory: InteractorFactory
    private var statusUpdateTimer: Timer?
    private var cachedAuthToken: CachedAuthToken?
    
    private let connectedText = "Connected"
    private let disconnectedText = "Disconnected"
    private let defaultConnectedMessage = "Your Internet is private"
    private let defaultDisconnectedMessage = "Your Internet is not private"
    private let defaultErrorAuthTokenMessage = "Error in fetching authentication token"
    
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
            let result = try await getInteractor.get()
            await handle(result)
        } catch let error {
            status = disconnectedText
            description = defaultDisconnectedMessage
            errorMessage = error.localizedDescription
        }
    }
    
    func connect() async {
        let token: Int
        if let authToken = cachedAuthToken, authToken.isExpired == false {
            token = authToken.token
            cachedAuthToken = nil
        } else {
            let authInteractor = interactorFactory.makeGetAuthTokenInteractor()
            do {
                switch try await authInteractor.get() {
                case .success(let response):
                    switch response.status {
                    case .success:
                        if let data = response.data {
                            token = data.auth_token
                            cachedAuthToken = CachedAuthToken(token: token,
                                                              expiry: Date().addingTimeInterval(5 * 60).timeIntervalSince1970)
                        } else {
                            self.status = disconnectedText
                            self.description = defaultDisconnectedMessage
                            self.errorMessage = defaultErrorAuthTokenMessage
                            return
                        }
                    case .error:
                        self.status = disconnectedText
                        self.description = defaultDisconnectedMessage
                        self.errorMessage = response.message ?? defaultErrorAuthTokenMessage
                        return
                    }
                case .failure(let networkApiError):
                    self.status = disconnectedText
                    self.description = defaultDisconnectedMessage
                    self.errorMessage = networkApiError.localizedDescription
                    return
                }
            } catch let error {
                self.status = disconnectedText
                self.description = defaultDisconnectedMessage
                self.errorMessage = error.localizedDescription
                return
            }
        }
        
        let connectInteractor = interactorFactory.makeConnectToVpn()
        do {
            let result = try await connectInteractor.connect(with: token)
            await handle(result)
        } catch let error {
            status = disconnectedText
            description = defaultDisconnectedMessage
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor private func handle(_ result: Result<ConnectionResponse, Error>) {
        switch result {
        case .success(let response):
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
            
        case .failure(let error):
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
}

//
//  ClientViewModel.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-15.
//

import Foundation

class ClientViewModel: ObservableObject {
    
    @Published var status: String = "..."
    @Published var token: String = "..."

    private let interactorFactory: InteractorFactory
    private var statusUpdateTimer: Timer?
    
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
    
    func getAuthToken() async {
        let authInteractor = interactorFactory.makeGetAuthTokenInteractor()
        do {
            switch try await authInteractor.get() {
            case .success(let response):
                await MainActor.run {
                    self.token = response.status.rawValue
                }
            case .failure(let networkApiError):
                await MainActor.run {
                    token = networkApiError.localizedDescription
                }
            }
            
        } catch let error {
            print("Getting error: \(error)")
        }
    }
    
    private func getStatus() async {
        let getInteractor = interactorFactory.makeGetConnectionStatus()
        do {
            switch try await getInteractor.get() {
            case .success(let response):
                await MainActor.run {
                    self.status = response.status.rawValue
                }
            case .failure(let socketApiError):
                await MainActor.run {
                    token = socketApiError.localizedDescription
                }
            }
            
        } catch let error {
            print("Getting error: \(error)")
        }
    }
}

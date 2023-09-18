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
    
    private let SOCKET_PATH = "/tmp/daemon-lite"
    private let decoder: JSONDecoder
    
    init() {
        self.decoder = JSONDecoder()
    }
    
    func getAuthToken() async {
        let authInteractor = GetAuthTokenFromRegistrationApi()
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
    
    func getStatus() async {
        let getInteractor = GetConnectionStatusFromDaemon()
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

//
//  GetConnectionStatusFromDaemon.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

class GetConnectionStatusFromDaemon: GetConnectionStatus {
    
    private let socketConnectionApi: SocketConnectionApi
    private let decoder: JSONDecoder
    
    init(socketConnectionApi: SocketConnectionApi = SocketConnectionInteractor()) {
        decoder = JSONDecoder()
        self.socketConnectionApi = socketConnectionApi
    }
    
    func get() async throws -> Result<ConnectionResponse, Error> {
        switch try await socketConnectionApi.data(for: .get_status) {
        case .success(let data):
            let response = try decoder.decode(ConnectionResponse.self, from: data)
            return .success(response)
        case .failure(let error):
            return .failure(error)
        }
    }
}

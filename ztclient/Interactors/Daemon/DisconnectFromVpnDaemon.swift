//
//  DisconnectFromVpnDaemon.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-18.
//

import Foundation

class DisconnectFromVpnDaemon: DisconnectFromVpn {
    
    private let socketConnectionApi: SocketConnectionApi
    private let decoder: JSONDecoder
    
    init(socketConnectionApi: SocketConnectionApi) {
        decoder = JSONDecoder()
        self.socketConnectionApi = socketConnectionApi
    }
    
    func disconnect() async throws -> Result<ConnectionResponse, Error> {
        switch try await socketConnectionApi.data(for: .disconnect) {
        case .success(let data):
            let response = try decoder.decode(ConnectionResponse.self, from: data)
            return .success(response)
        case .failure(let error):
            return .failure(error)
        }
    }
}

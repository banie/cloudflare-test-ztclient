//
//  ConnectToVpnFromDaemon.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-18.
//

import Foundation

class ConnectToVpnFromDaemon: ConnectToVpn {
    
    private let socketConnectionApi: SocketConnectionApi
    private let decoder: JSONDecoder
    
    init(socketConnectionApi: SocketConnectionApi = SocketConnectionInteractor()) {
        decoder = JSONDecoder()
        self.socketConnectionApi = socketConnectionApi
    }
    
    func connect(with token: Int) async throws -> Result<ConnectionResponse, Error> {
        switch try await socketConnectionApi.data(for: .connect(token)) {
        case .success(let data):
            let response = try decoder.decode(ConnectionResponse.self, from: data)
            return .success(response)
        case .failure(let error):
            return .failure(error)
        }
    }
}

//
//  SocketConnectionApi.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

protocol SocketConnectionApi {
    func data(for request: DaemonRequest) async throws -> Result<Data, SocketApiError>
}

public enum SocketApiError: Error {
    case socketCreationFailure
    case socketConnectionFailure
    case serializationFailure(Error)
}

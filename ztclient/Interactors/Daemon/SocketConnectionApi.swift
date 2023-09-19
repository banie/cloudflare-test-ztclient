//
//  SocketConnectionApi.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

protocol SocketConnectionApi {
    func openSocketConnection() async -> Result<Int32, SocketApiError>
    func data(for request: DaemonRequest) async throws -> Result<Data, SocketApiError>
    func closeSocketConnection()
}

public enum SocketApiError: Error {
    case socketCreationFailure
    case socketConnectionFailure
    case requestBeforeEstablishConnection
    case serializationFailure(Error)
    case payloadSizeWriteFailure
    case payloadWriteFailure
    case payloadSizeReadFailure
    case payloadReadFailure
}

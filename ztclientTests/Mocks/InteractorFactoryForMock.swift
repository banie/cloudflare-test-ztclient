//
//  InteractorFactoryForMock.swift
//  ztclientTests
//
//  Created by banie setijoso on 2023-09-19.
//

import Foundation

@testable import ztclient

class InteractorFactoryForMock: InteractorFactory {
    
    let getAuthTokenMock: GetAuthTokenMock
    let getConnectionStatusMock: GetConnectionStatusMock
    let disconnectFromVpnMock: DisconnectFromVpnMock
    let connectToVpnMock: ConnectToVpnMock
    let socketConnectionApiMock: SocketConnectionApiMock
    
    init() {
        getAuthTokenMock = GetAuthTokenMock()
        getConnectionStatusMock = GetConnectionStatusMock()
        disconnectFromVpnMock = DisconnectFromVpnMock()
        connectToVpnMock = ConnectToVpnMock()
        socketConnectionApiMock = SocketConnectionApiMock()
    }
    
    func makeGetAuthTokenInteractor() -> GetAuthToken {
        getAuthTokenMock
    }
    
    func makeGetConnectionStatus(using socketApi: SocketConnectionApi) -> GetConnectionStatus {
        getConnectionStatusMock
    }
    
    func makeDisconnectFromVpn(using socketApi: SocketConnectionApi) -> DisconnectFromVpn {
        disconnectFromVpnMock
    }
    
    func makeConnectToVpn(using socketApi: SocketConnectionApi) -> ConnectToVpn {
        connectToVpnMock
    }
    
    func makeSocketConnectionApi() -> SocketConnectionApi {
        socketConnectionApiMock
    }
}

class GetAuthTokenMock: GetAuthToken {
    var getSpy: (() async throws -> Result<AuthenticationTokenResponse, NetworkApiError>)?
    var getResult: Result<AuthenticationTokenResponse, NetworkApiError>?
    func get() async throws -> Result<AuthenticationTokenResponse, NetworkApiError> {
        try await getSpy?() ?? getResult ?? .failure(.urlIsInvalid)
    }
}

class GetConnectionStatusMock: GetConnectionStatus {
    var getSpy: (() async throws -> Result<ConnectionResponse, Error>)?
    var getResult: Result<ConnectionResponse, Error>?
    func get() async throws -> Result<ConnectionResponse, Error> {
        try await getSpy?() ?? getResult ?? .failure(SocketApiError.payloadSizeWriteFailure)
    }
}

class ConnectToVpnMock: ConnectToVpn {
    var connectSpy: (() async throws -> Result<ConnectionResponse, Error>)?
    var connectResult: Result<ConnectionResponse, Error>?
    func connect(with token: Int) async throws -> Result<ConnectionResponse, Error> {
        try await connectSpy?() ?? connectResult ?? .failure(SocketApiError.payloadWriteFailure)
    }
}

class DisconnectFromVpnMock: DisconnectFromVpn {
    var disconnectSpy: (() async throws -> Result<ConnectionResponse, Error>)?
    var disconnectResult: Result<ConnectionResponse, Error>?
    func disconnect() async throws -> Result<ConnectionResponse, Error> {
        try await disconnectSpy?() ?? disconnectResult ?? .failure(SocketApiError.requestBeforeEstablishConnection)
    }
}

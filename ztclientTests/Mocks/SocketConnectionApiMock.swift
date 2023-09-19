//
//  SocketConnectionApiMock.swift
//  ztclientTests
//
//  Created by banie setijoso on 2023-09-19.
//

import Foundation

@testable import ztclient

class SocketConnectionApiMock: SocketConnectionApi {
    
    var openSocketConnectionSpy: (() async -> Result<Int32, SocketApiError>)?
    var openSocketConnectionResult: Result<Int32, SocketApiError>?
    func openSocketConnection() async -> Result<Int32, ztclient.SocketApiError> {
        await openSocketConnectionSpy?() ?? openSocketConnectionResult ?? .failure(.payloadReadFailure)
    }
    
    var dataSpy: ((_ request: DaemonRequest) async throws -> Result<Data, SocketApiError>)?
    var dataResult: Result<Data, ztclient.SocketApiError>?
    func data(for request: DaemonRequest) async throws -> Result<Data, SocketApiError> {
        try await dataSpy?(request) ?? dataResult ?? .failure(.payloadSizeReadFailure)
    }
    
    var closeSocketConnectionSpy: (() -> Void)?
    func closeSocketConnection() {
        closeSocketConnectionSpy?()
    }
}

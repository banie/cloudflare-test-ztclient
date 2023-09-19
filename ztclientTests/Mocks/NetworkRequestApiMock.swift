//
//  NetworkRequestApiMock.swift
//  PenguinPayTests
//
//  Created by Banie Setijoso on 2023-02-02.
//

import XCTest

@testable import ztclient

class NetworkRequestApiMock: NetworkRequestApi {
    var dataSpy: ((_ request: URLRequest) async throws -> Result<Data, NetworkApiError>)?
    var dataResult: Result<Data, NetworkApiError>?
    
    func data(for request: URLRequest) async throws -> Result<Data, NetworkApiError> {
        try await dataSpy?(request) ?? dataResult ?? .failure(.urlIsInvalid)
    }
}

//
//  SessionApi.swift
//  PenguinPay
//
//  Created by Banie Setijoso on 2023-02-02.
//

import Foundation

public protocol NetworkRequestApi {
    func data(for request: URLRequest) async throws -> Result<Data, NetworkApiError>
}

public enum NetworkApiError: Error {
    case urlIsInvalid
    case failed(statusCode: Int)
}

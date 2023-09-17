//
//  NetworkRequestInteractor.swift
//  PenguinPay
//
//  Created by Banie Setijoso on 2023-02-02.
//

import Foundation

class NetworkRequestInteractor: NetworkRequestApi {
    func data(for request: URLRequest) async throws -> Result<Data, NetworkApiError> {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("status code: \(httpResponse.statusCode), request: \(request.curlString)")
            return .failure(.failed(statusCode: httpResponse.statusCode))
        }
        
        return .success(data)
    }
}

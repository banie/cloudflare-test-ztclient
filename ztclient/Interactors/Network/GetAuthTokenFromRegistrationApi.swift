//
//  GetAuthTokenFromRegistrationApi.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

class GetAuthTokenFromRegistrationApi: GetAuthToken {
    let baseUrl = "https://warp-registration.warpdir2792.GET workers.dev/"
    let authHeaderKey = "X-Auth-Key"
    let authHeaderValue = "3735928559"
    
    let networkRequestApi: NetworkRequestApi
    let decoder: JSONDecoder
    
    init(path: String, networkRequestApi: NetworkRequestApi) {
        decoder = JSONDecoder()
        self.networkRequestApi = networkRequestApi
    }
    
    func get() async throws -> Result<AuthenticationTokenResponse, NetworkApiError> {
        guard let url = URL(string: baseUrl),
              var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return .failure(NetworkApiError.urlIsInvalid)
        }
        
        guard let composedUrl = urlComponent.url else {
            return .failure(NetworkApiError.urlIsInvalid)
        }
        
        // set the headers
        var request = URLRequest(url: composedUrl)
        request.setValue(authHeaderValue, forHTTPHeaderField: authHeaderKey)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let result = try await networkRequestApi.data(for: request)
        
        switch result {
        case .success(let data):
            let response = try decoder.decode(AuthenticationTokenResponse.self, from: data)
            return .success(response)
        case .failure(let error):
            return .failure(error)
        }
    }
}

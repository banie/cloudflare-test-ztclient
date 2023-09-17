//
//  GetAuthToken.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

protocol GetAuthToken {
    func get() async throws -> Result<AuthenticationTokenResponse, NetworkApiError>
}

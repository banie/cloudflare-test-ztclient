//
//  AuthenticationTokenResponse.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

struct AuthenticationTokenResponse: Codable {
    let status: RequestStatus
    let message: String?
    let data: RegistrationResponseData?
}

struct RegistrationResponseData: Codable {
    let auth_token: Int
}

//
//  DisconnectFromVpn.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-18.
//

import Foundation

protocol DisconnectFromVpn {
    func disconnect() async throws -> Result<ConnectionResponse, Error>
}

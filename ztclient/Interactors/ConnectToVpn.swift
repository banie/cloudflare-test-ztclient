//
//  ConnectToVpn.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-18.
//

import Foundation

protocol ConnectToVpn {
    func connect(with token: Int) async throws -> Result<ConnectionResponse, Error>
}

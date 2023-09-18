//
//  GetConnectionStatus.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

protocol GetConnectionStatus {
    func get() async throws -> Result<ConnectionResponse, Error>
}

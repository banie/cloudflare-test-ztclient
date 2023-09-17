//
//  ConnectionResponse.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

struct ConnectionResponse: Codable {
    let status: RequestStatus
    let message: String?
    let data: DaemonResponseData?
}

struct DaemonResponseData: Codable {
    let daemon_status: DaemonStatus
    let message: String?
}

enum DaemonStatus: String, Codable {
    case connected
    case disconnected
}

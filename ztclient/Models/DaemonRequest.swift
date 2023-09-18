//
//  DaemonRequest.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

enum DaemonRequest: Codable {
    case connect(Int64)
    case disconnect
    case get_status

    enum CodingKeys: String, CodingKey {
        case request
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let connectContainer = try? container.nestedContainer(keyedBy: ConnectKeys.self, forKey: .request),
           let value = try? connectContainer.decode(Int64.self, forKey: .connect) {
            self = .connect(value)
            return
        }

        let requestValue = try container.decode(String.self, forKey: .request)
        switch requestValue {
        case "disconnect":
            self = .disconnect
        case "get_status":
            self = .get_status
        default:
            throw DecodingError.dataCorruptedError(forKey: .request, in: container, debugDescription: "Invalid request value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .connect(let value):
            var nestedContainer = container.nestedContainer(keyedBy: ConnectKeys.self, forKey: .request)
            try nestedContainer.encode(value, forKey: .connect)
        case .disconnect:
            try container.encode("disconnect", forKey: .request)
        case .get_status:
            try container.encode("get_status", forKey: .request)
        }
    }
    
    enum ConnectKeys: String, CodingKey {
        case connect
    }
}

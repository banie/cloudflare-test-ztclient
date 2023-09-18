//
//  SocketConnectionInteractor.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

class SocketConnectionInteractor: SocketConnectionApi {
    private let SOCKET_PATH = "/tmp/daemon-lite"
    private let encoder: JSONEncoder

    init() {
        self.encoder = JSONEncoder()
    }
    
    func data(for request: DaemonRequest) async throws -> Result<Data, SocketApiError> {
        // Create and configure socket
        let socketFD = socket(AF_UNIX, SOCK_STREAM, 0)
        guard socketFD != -1 else {
            return .failure(.socketCreationFailure)
        }
        
        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        strcpy(&addr.sun_path, SOCKET_PATH)
        
        let result = withUnsafePointer(to: addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.connect(socketFD, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        
        guard result != -1 else {
            close(socketFD)
            return .failure(.socketConnectionFailure)
        }

        // Successfully connected to the socket, proceed with sending payload size and payload
        let payloadData: Data
        do {
            payloadData = try encoder.encode(request)
        } catch let parseError {
            close(socketFD)
            return .failure(.serializationFailure(parseError))
        }
        
        let payloadSize = UInt64(payloadData.count)
        let payloadSizeData = withUnsafeBytes(of: payloadSize.littleEndian) { Data($0) }
        
        write(socketFD, [UInt8](payloadSizeData), payloadSizeData.count)
        write(socketFD, [UInt8](payloadData), payloadData.count)
        
        // Read response payload size
        var responsePayloadSize: UInt64 = 0
        read(socketFD, &responsePayloadSize, MemoryLayout<UInt64>.size)
        responsePayloadSize = UInt64(littleEndian: responsePayloadSize)
        
        // Read response payload
        var responsePayloadData = Data(count: Int(responsePayloadSize))
        _ = responsePayloadData.withUnsafeMutableBytes { ptr in
            read(socketFD, ptr.bindMemory(to: UInt8.self).baseAddress, Int(responsePayloadSize))
        }
        
        close(socketFD)
        
        return .success(responsePayloadData)
    }
}

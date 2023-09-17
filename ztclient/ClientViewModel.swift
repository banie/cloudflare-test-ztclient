//
//  ClientViewModel.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-15.
//

import Foundation

class ClientViewModel: ObservableObject {
    
    @MainActor var status: String = "..."
    
    private let SOCKET_PATH = "/tmp/daemon-lite"
    
    func getStatus() async {
        // Define payload
        let sendPayload: [String: Any] = [
            "request": "get_status"
        ]
        
        // Serialize payload to JSON
        do {
            // Create and configure socket
            let socketFD = socket(AF_UNIX, SOCK_STREAM, 0)
            guard socketFD != -1 else {
                print("Failed to create socket")
                exit(EXIT_FAILURE)
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
                perror("Failed to connect to socket")
                exit(EXIT_FAILURE)
            }

            // Successfully connected to the socket, proceed with sending payload size and payload
            let sendPayloadData = try JSONSerialization.data(withJSONObject: sendPayload, options: [])
            let payloadSize = UInt64(sendPayloadData.count)
            let payloadSizeData = withUnsafeBytes(of: payloadSize.littleEndian) { Data($0) }
            let payloadData = sendPayloadData
            
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
            
            // Deserialize response payload to JSON
            if let responsePayload = try? JSONSerialization.jsonObject(with: responsePayloadData, options: []) as? [String: Any] {
                print("Received response: \(responsePayload)")
                await MainActor.run {
                    status = responsePayload.debugDescription
                }
            } else {
                print("Failed to deserialize response payload")
            }
            
            // Close the socket
            close(socketFD)
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
        }
    }
}

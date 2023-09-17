//
//  ClientViewModel.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-15.
//

import Foundation

class ClientViewModel: ObservableObject {
    
    @Published var status: String = "..."
    @Published var token: String = "..."
    
    private let SOCKET_PATH = "/tmp/daemon-lite"
    private let decoder: JSONDecoder
    
    init() {
        self.decoder = JSONDecoder()
    }
    
    func getAuthToken() async {
        let authInteractor = GetAuthTokenFromRegistrationApi()
        do {
            switch try await authInteractor.get() {
            case .success(let response):
                await MainActor.run {
                    self.token = response.status.rawValue
                }
            case .failure(let networkApiError):
                await MainActor.run {
                    token = networkApiError.localizedDescription
                }
            }
            
        } catch let error {
            print("Getting error: \(error)")
        }
    }
    
    func getStatus() async {
        // Define payload to get status
        let getStatusPayload: [String: Any] = [
            "request": "get_status"
        ]
    
        // Create and configure socket
        let socketFD = socket(AF_UNIX, SOCK_STREAM, 0)
        guard socketFD != -1 else {
            perror("Failed to create socket")
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
        do {
            let payloadData = try JSONSerialization.data(withJSONObject: getStatusPayload, options: [])
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
            
            // Deserialize response payload to our codable struct
            let responseModel = try decoder.decode(ConnectionResponse.self, from: responsePayloadData)
            print("Received response: \(responseModel)")
            await MainActor.run {
                status = responseModel.status.rawValue
            }
        } catch let parseError {
            print("Failed to serialize JSON: \(parseError.localizedDescription)")
        }
        
        close(socketFD)
    }
}

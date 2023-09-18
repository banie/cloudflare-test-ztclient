//
//  DaemonRequestTests.swift
//  ztclientTests
//
//  Created by banie setijoso on 2023-09-17.
//

import XCTest

@testable import ztclient

final class DaemonRequestTests: XCTestCase {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func testGetStatusEncodingDecoding() throws {
        let original = DaemonRequest.get_status
        let data = try JSONEncoder().encode(original)
        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertEqual(jsonString, "{\"request\":\"get_status\"}")
        
        let decoded = try JSONDecoder().decode(DaemonRequest.self, from: data)
        if case .get_status = decoded {
            // Success
        } else {
            XCTFail("Decoded value is not .get_status")
        }
    }

    func testDisconnectEncodingDecoding() throws {
        let original = DaemonRequest.disconnect
        let data = try JSONEncoder().encode(original)
        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertEqual(jsonString, "{\"request\":\"disconnect\"}")
        
        let decoded = try JSONDecoder().decode(DaemonRequest.self, from: data)
        if case .disconnect = decoded {
            // Success
        } else {
            XCTFail("Decoded value is not .disconnect")
        }
    }
    
    func testConnectEncodingDecoding() throws {
        let original = DaemonRequest.connect(245346437489485)
        let data = try encoder.encode(original)
        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertEqual(jsonString, "{\"request\":{\"connect\":245346437489485}}")
        
        let decoded = try decoder.decode(DaemonRequest.self, from: data)
        if case .connect(let value) = decoded {
            XCTAssertEqual(value, 245346437489485)
        } else {
            XCTFail("Decoded value is not .connect")
        }
    }
}

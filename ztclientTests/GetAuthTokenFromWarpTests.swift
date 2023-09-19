//
//  GetAuthTokenFromWarpTests.swift
//  ztclientTests
//
//  Created by banie setijoso on 2023-09-19.
//

import XCTest

@testable import ztclient

final class GetAuthTokenFromWarpTests: XCTestCase {
    
    private var apiMock: NetworkRequestApiMock!
    private var interactor: GetAuthTokenFromWarp!

    override func setUpWithError() throws {
        apiMock = NetworkRequestApiMock()
        interactor = GetAuthTokenFromWarp(networkRequestApi: apiMock)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSuccessRequest() async throws {
        let sampleResponse = """
        {
            "status": "success",
            "data": {
                "auth_token": 245346444925233
            }
        }
        """.data(using: .utf8)!
        
        let requestExpectation = expectation(description: "request is made")
        apiMock.dataSpy = { request in
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)
            
            XCTAssertEqual(components?.url?.absoluteString, self.interactor.baseUrl)
            XCTAssertEqual(self.interactor.authHeaderValue, request.value(forHTTPHeaderField: self.interactor.authHeaderKey))
            XCTAssertEqual("application/json", request.value(forHTTPHeaderField: "Content-Type"))
            
            requestExpectation.fulfill()
            return .success(sampleResponse)
        }
        
        switch try await interactor.get() {
        case .success(let tokenResponse):
            XCTAssertEqual(tokenResponse.status, .success)
            XCTAssertNil(tokenResponse.message)
            XCTAssertNotNil(tokenResponse.data)
            if let data = tokenResponse.data {
                XCTAssertEqual(data.auth_token, 245346444925233)
            }
        case .failure:
            XCTFail("Should not fail here, the response given is a successful one")
        }
        
        await fulfillment(of: [requestExpectation])
    }
    
    func testInvalidAuthKey() async throws {
        let sampleResponse = """
        {
            "status": "error",
            "message": "Invalid authentication key"
        }
        """.data(using: .utf8)!
        
        let requestExpectation = expectation(description: "request is made")
        apiMock.dataSpy = { request in
            requestExpectation.fulfill()
            return .success(sampleResponse)
        }
        
        switch try await interactor.get() {
        case .success(let tokenResponse):
            XCTAssertEqual(tokenResponse.status, .error)
            XCTAssertNotNil(tokenResponse.message)
            XCTAssertNil(tokenResponse.data)
            if let message = tokenResponse.message {
                XCTAssertEqual(message, "Invalid authentication key")
            }
        case .failure:
            XCTFail("Should not fail here, the response given is a successful one")
        }
        
        await fulfillment(of: [requestExpectation])
    }
    
    func testOtherError() async throws {
        let sampleResponse = """
        {
            "status": "error",
            "message": "An active incident is currently affecting this API (ICDT-1234). Please consult our status page for more details: https://www.cloudflarestatus.com/"
        }
        """.data(using: .utf8)!
        
        let requestExpectation = expectation(description: "request is made")
        apiMock.dataSpy = { request in
            requestExpectation.fulfill()
            return .success(sampleResponse)
        }
        
        switch try await interactor.get() {
        case .success(let tokenResponse):
            XCTAssertEqual(tokenResponse.status, .error)
            XCTAssertNotNil(tokenResponse.message)
            XCTAssertNil(tokenResponse.data)
            if let message = tokenResponse.message {
                XCTAssertEqual(message, "An active incident is currently affecting this API (ICDT-1234). Please consult our status page for more details: https://www.cloudflarestatus.com/")
            }
        case .failure:
            XCTFail("Should not fail here, the response given is a successful one")
        }
        
        await fulfillment(of: [requestExpectation])
    }
}


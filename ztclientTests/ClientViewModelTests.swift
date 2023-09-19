//
//  ClientViewModelTests.swift
//  ztclientTests
//
//  Created by banie setijoso on 2023-09-19.
//

import XCTest

@testable import ztclient

final class ClientViewModelTests: XCTestCase {
    var viewModel: ClientViewModel!
    var interactorFactoryForMock: InteractorFactoryForMock!
    var socketConnectorMock: SocketConnectionApiMock!
    
    override func setUp() {
        super.setUp()
        interactorFactoryForMock = InteractorFactoryForMock()
        viewModel = ClientViewModel(interactorFactory: interactorFactoryForMock)
    }
    
    @MainActor func testOnAppDidLoad() {
        let openSocketExpectation = expectation(description: "open socket request is made")
        interactorFactoryForMock.socketConnectionApiMock.openSocketConnectionSpy = {
            openSocketExpectation.fulfill()
            return .success(123)
        }
        
        viewModel.onAppDidLoad()
        
        XCTAssertEqual(viewModel.status, "Disconnected")
        XCTAssertEqual(viewModel.description, "Your Internet is not private")
        XCTAssertEqual(viewModel.errorMessage, "")
        
        wait(for: [openSocketExpectation], timeout: 1)
    }
    
    func testOnAppWillTerminate() async {
        let closeSocketExpectation = expectation(description: "close socket request is made")
        interactorFactoryForMock.socketConnectionApiMock.closeSocketConnectionSpy = {
            closeSocketExpectation.fulfill()
        }
        
        viewModel.onAppWillTerminate()
        
        await fulfillment(of: [closeSocketExpectation], timeout: 1)
    }
}

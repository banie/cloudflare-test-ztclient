//
//  InteractorFactory.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

protocol InteractorFactory {
    func makeGetAuthTokenInteractor() -> GetAuthToken
    func makeGetConnectionStatus() -> GetConnectionStatus
    func makeDisconnectFromVpn() -> DisconnectFromVpn
    func makeConnectToVpn() -> ConnectToVpn
}

class InteractorFactoryForProduction: InteractorFactory {
    func makeGetAuthTokenInteractor() -> GetAuthToken {
        GetAuthTokenFromRegistrationApi()
    }
    
    func makeGetConnectionStatus() -> GetConnectionStatus {
        GetConnectionStatusFromDaemon()
    }
    
    func makeDisconnectFromVpn() -> DisconnectFromVpn {
        DisconnectFromVpnDaemon()
    }
    
    func makeConnectToVpn() -> ConnectToVpn {
        ConnectToVpnFromDaemon()
    }
}

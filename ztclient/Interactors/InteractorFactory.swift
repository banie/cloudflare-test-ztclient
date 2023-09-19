//
//  InteractorFactory.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-17.
//

import Foundation

protocol InteractorFactory {
    func makeGetAuthTokenInteractor() -> GetAuthToken
    func makeGetConnectionStatus(using socketApi: SocketConnectionApi) -> GetConnectionStatus
    func makeDisconnectFromVpn(using socketApi: SocketConnectionApi) -> DisconnectFromVpn
    func makeConnectToVpn(using socketApi: SocketConnectionApi) -> ConnectToVpn
    func makeSocketConnectionApi() -> SocketConnectionApi
}

class InteractorFactoryForProduction: InteractorFactory {
    func makeGetAuthTokenInteractor() -> GetAuthToken {
        GetAuthTokenFromWarp()
    }
    
    func makeGetConnectionStatus(using socketApi: SocketConnectionApi) -> GetConnectionStatus {
        GetConnectionStatusFromDaemon(socketConnectionApi: socketApi)
    }
    
    func makeDisconnectFromVpn(using socketApi: SocketConnectionApi) -> DisconnectFromVpn {
        DisconnectFromVpnDaemon(socketConnectionApi: socketApi)
    }
    
    func makeConnectToVpn(using socketApi: SocketConnectionApi) -> ConnectToVpn {
        ConnectToVpnFromDaemon(socketConnectionApi: socketApi)
    }
    
    func makeSocketConnectionApi() -> SocketConnectionApi {
        SocketConnector()
    }
}

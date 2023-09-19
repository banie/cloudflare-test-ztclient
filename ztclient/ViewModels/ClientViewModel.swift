//
//  ClientViewModel.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-15.
//

import Foundation

struct CachedAuthToken {
    let token: Int
    let expiry: Double
    
    var isExpired: Bool {
        Date().timeIntervalSince1970 > expiry
    }
}

class ClientViewModel: ObservableObject {
    
    @Published var status: String = "..."
    @Published var description: String = "..."
    @Published var errorMessage: String = ""
    @Published var isToggleOn: Bool = false {
                    didSet {
                        if userInitiated {
                            toggleStateChanged()
                        }
                    }
                }

    private var userInitiated = true
    private var statusUpdateTimer: Timer?
    private var cachedAuthToken: CachedAuthToken?
    
    private let interactorFactory: InteractorFactory
    private let connectedText = "Connected"
    private let disconnectedText = "Disconnected"
    private let defaultConnectedMessage = "Your Internet is private"
    private let defaultDisconnectedMessage = "Your Internet is not private"
    private let defaultErrorAuthTokenMessage = "There is no data returned in the authentication request"
    
    init(interactorFactory: InteractorFactory = InteractorFactoryForProduction()) {
        self.interactorFactory = interactorFactory
    }
    
    deinit {
        pause()
    }
    
    @MainActor func onAppDidLoad() {
        showDisconnect()
    }
    
    /**
     start calling getStatus and repeat it every 5s
     */
    func start() {
        statusUpdateTimer?.invalidate()
        statusUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task.detached {
                await self.getStatus()
            }
        }
    }
    
    /**
     pause the timer to call getStatus, for example when app goes to background
     */
    func pause() {
        statusUpdateTimer?.invalidate()
        statusUpdateTimer = nil
    }
    
    private func toggleStateChanged() {
        Task.detached { [self] in
            await showPendingState()
            if self.isToggleOn {
                await connect()
            } else {
                await disconnect()
            }
        }
    }
    
    private func getStatus() async {
        let getInteractor = interactorFactory.makeGetConnectionStatus()
        do {
            let result = try await getInteractor.get()
            await handle(result)
        } catch let error {
            status = disconnectedText
            description = defaultDisconnectedMessage
            errorMessage = error.localizedDescription
        }
    }
    
    private func disconnect() async {
        let getInteractor = interactorFactory.makeDisconnectFromVpn()
        do {
            let result = try await getInteractor.disconnect()
            await handle(result)
        } catch let error {
            status = disconnectedText
            description = defaultDisconnectedMessage
            errorMessage = error.localizedDescription
        }
    }
    
    private func connect() async {
        let token: Int
        if let authToken = cachedAuthToken, authToken.isExpired == false {
            token = authToken.token
        } else {
            let authInteractor = interactorFactory.makeGetAuthTokenInteractor()
            do {
                switch try await authInteractor.get() {
                case .success(let response):
                    switch response.status {
                    case .success:
                        if let data = response.data {
                            token = data.auth_token
                            cachedAuthToken = CachedAuthToken(token: token,
                                                              expiry: Date().addingTimeInterval(5 * 60).timeIntervalSince1970)
                        } else {
                            await showDisconnect(with: defaultErrorAuthTokenMessage)
                            return
                        }
                    case .error:
                        await showDisconnect(with: response.message)
                        return
                    }
                case .failure(let networkApiError):
                    await showDisconnect(with: networkApiError.localizedDescription)
                    return
                }
            } catch let error {
                await showDisconnect(with: error.localizedDescription)
                return
            }
        }
        
        let connectInteractor = interactorFactory.makeConnectToVpn()
        do {
            let result = try await connectInteractor.connect(with: token)
            await handle(result)
        } catch let error {
            status = disconnectedText
            description = defaultDisconnectedMessage
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor private func handle(_ result: Result<ConnectionResponse, Error>) {
        switch result {
        case .success(let response):
            switch response.status {
            case .success:
                if let data = response.data {
                    switch data.daemon_status {
                    case .connected:
                        cachedAuthToken = nil
                        updateToggleStateProgrammatically(with: true)
                        status = connectedText
                        description = defaultConnectedMessage
                        errorMessage = ""
                    case .disconnected:
                        showDisconnect(with: data.message)
                    }
                }
            case .error:
                showErrorMessage(with: response.message)
            }
            
        case .failure(let error):
            if let socketApiError = error as? SocketApiError {
                switch socketApiError {
                case .socketCreationFailure:
                    showErrorMessage(with: "Failed in creating the Socket")
                case .socketConnectionFailure:
                    showErrorMessage(with: "Failed in connecting to the Socket")
                case .serializationFailure(let serializationError):
                    showErrorMessage(with: "Failed in serializing the data to the Socket. \(serializationError.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor private func showDisconnect(with errorText: String? = nil) {
        updateToggleStateProgrammatically(with: false)
        status = disconnectedText
        description = defaultDisconnectedMessage
        showErrorMessage(with: errorText)
    }
    
    @MainActor private func showErrorMessage(with errorText: String? = nil) {
        errorMessage = errorText ?? ""
    }
    
    @MainActor private func updateToggleStateProgrammatically(with value: Bool) {
        userInitiated = false
        isToggleOn = value
        userInitiated = true
    }
    
    @MainActor private func showPendingState() {
        status = "..."
        description = "..."
        errorMessage = ""
    }
}

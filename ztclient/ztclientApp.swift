//
//  ztclientApp.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-13.
//

import SwiftUI

@main
struct ztclientApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: appDelegate.viewModel)
                .frame(width: 300, height: 400)
                .frame(minWidth: 300, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity, alignment: .center)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 300, height: 400)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let viewModel = ClientViewModel()

    func applicationDidBecomeActive(_ notification: Notification) {
        viewModel.start()
    }

    func applicationWillResignActive(_ notification: Notification) {
        viewModel.pause()
    }
    
    func applicationWillUnhide(_ notification: Notification) {
        viewModel.start()
    }
    
    func applicationWillHide(_ notification: Notification) {
        viewModel.pause()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        viewModel.pause()
    }
}

//
//  ContentView.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-13.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ClientViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Text(viewModel.status)
            Text(viewModel.token)
        }
        .padding(20)
        .onAppear() {
            Task.detached {
                await self.viewModel.getStatus()
                await self.viewModel.getAuthToken()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

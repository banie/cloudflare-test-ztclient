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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Text(viewModel.status)
        }
        .padding()
        .onAppear() {
            Task.detached {
                await self.viewModel.getStatus()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

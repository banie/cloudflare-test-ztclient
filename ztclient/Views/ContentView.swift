//
//  ContentView.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-13.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: ClientViewModel
    
    @State private var isOn = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Cloudflare ZT Client")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Toggle("", isOn: $isOn)
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                        .scaleEffect(3.0)
                        .padding()
            Text(viewModel.status)
                .font(.title)
            Text(viewModel.description)
                .font(.title2)
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
        }
        .padding(20)
        .onAppear() {
            viewModel.refresh()
            Task.detached {
                await self.viewModel.getAuthToken()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ClientViewModel())
    }
}

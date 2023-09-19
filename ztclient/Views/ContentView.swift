//
//  ContentView.swift
//  ztclient
//
//  Created by banie setijoso on 2023-09-13.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: ClientViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Cloudflare ZT Client")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Toggle("", isOn: $viewModel.isToggleOn)
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
            viewModel.start()
        }
        .onDisappear() {
            viewModel.pause()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ClientViewModel())
    }
}

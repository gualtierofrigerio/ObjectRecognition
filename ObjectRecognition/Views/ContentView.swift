//
//  ContentView.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 27/04/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button {
                showCamera.toggle()
            } label: {
                Text("scan for objects")
            }
            .padding()
            Button {
                showLibrary.toggle()
            } label: {
                Text("open library")
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView()
        }
        .sheet(isPresented: $showLibrary) {
            PhotoLibraryView()
        }
    }
    
    @State private var showCamera = false
    @State private var showLibrary = false
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

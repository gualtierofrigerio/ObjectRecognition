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
                showSheet.toggle()
            } label: {
                Text("scan for objects")
            }
        }
        .sheet(isPresented: $showSheet) {
            CameraView()
        }
    }
    
    @State private var showSheet = false
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

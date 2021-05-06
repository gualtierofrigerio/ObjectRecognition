//
//  PhotoLibraryView.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 06/05/21.
//

import SwiftUI

struct PhotoLibraryView: View {
    @ObservedObject var viewModel = PhotoLibraryViewModel()
    
    var body: some View {
        VStack {
            Button {
                viewModel.showPicker.toggle()
            } label: {
                Text("open photo library")
            }
            if viewModel.showImageAndButton {
                Image(uiImage:viewModel.selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height:200)
                Button {
                    print("start recognition")
                    viewModel.startRecognition()
                } label: {
                    Text("start recognition")
                }
            }
        }
        .sheet(isPresented: $viewModel.showPicker) {
            PhotoPicker(delegate: viewModel)
        }
        .sheet(isPresented: $viewModel.showImageViewOverlay) {
            ImageOverlayView(image: viewModel.selectedImage)
            //.frame(width:200, height:200)
        }
    }
}

struct PhotoLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoLibraryView()
    }
}

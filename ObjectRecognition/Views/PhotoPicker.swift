//
//  PhotoPicker.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 06/05/21.
//

import SwiftUI
import UIKit

struct PhotoPicker: UIViewControllerRepresentable {
    let delegate:PhotoLibraryViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPicker>) -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = delegate
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<PhotoPicker>) {
        
    }
}


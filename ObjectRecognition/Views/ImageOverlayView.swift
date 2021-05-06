//
//  ImageViewOverlay.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 06/05/21.
//

import SwiftUI
import UIKit

struct ImageOverlayView: UIViewControllerRepresentable {
    var image:UIImage
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImageOverlayView>) -> UIViewController {
        
        let viewController = ImageOverlayViewController(image: image)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ImageOverlayView>) {
        
    }
}

//
//  ImageOverlayViewController.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 06/05/21.
//

import Foundation
import UIKit
import Vision

class ImageOverlayViewController: UIViewController {
    
    
    init(image:UIImage) {
        self.image = image
        self.imageView = UIImageView(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.frame
        view.addSubview(imageView)
        
        let recognizer = ObjectRecognizer()
        recognizer.recognize(fromImage: image) { objects in
            self.drawRecognizedObjects(objects)
        }
    }
    
    private func drawRecognizedObjects(_ objects:[RecognizedObject]) {
        let imageFrame = GeometryUtils.imageFrameInView(imageSize: image.size, viewSize: imageView.frame.size)
        let objectsLayer = GeometryUtils.createLayer(forRecognizedObjects: objects,
                                                     inFrame: imageFrame)
        view.layer.addSublayer(objectsLayer)
    }
    
    // MARK: - Private
    private let image:UIImage
    private let imageView:UIImageView
}


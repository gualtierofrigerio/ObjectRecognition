//
//  ObjectRecognizer.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 29/04/21.
//

import Foundation
import UIKit
import Vision

struct RecognizedObject {
    var bounds:CGRect
    var label:String
    var confidence:Float
}

class ObjectRecognizer {
    var preferredSize:CGSize {
        CGSize(width: 416, height: 416)
    }
    
    init() {
        loadModel()
    }
    
    func recognize(fromImage image:UIImage,
                   completion:@escaping([RecognizedObject]) ->Void ) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        self.completion = completion
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        }
        catch {
            print(error)
        }
    }
    
    func recognize(fromPixelBuffer pixelBuffer:CVImageBuffer,
                   completion:@escaping([RecognizedObject]) ->Void ) {
        self.completion = completion
        let exifOrientation = OrientationUtils.exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: exifOrientation,
                                                        options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        }
        catch {
            print(error)
        }
    }
    
    // MARK: - Private
    
    private func loadModel() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3Tiny", withExtension: "mlmodelc") else { return }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                if let results = request.results {
                    self.processResults(results)
                }
                else {
                    print("no results error \(String(describing: error?.localizedDescription))")
                }
            })
            objectRecognition.imageCropAndScaleOption = .scaleFit
            self.requests = [objectRecognition]
        }
        catch let error as NSError {
            print("Error while loading model: \(error)")
        }
    }
    
    private func processResults(_ results:[Any]) {
        var recognizedObjects:[RecognizedObject] = []
        for result in results {
            guard let vnResult = result as? VNRecognizedObjectObservation,
                  let label = vnResult.labels.first else {
                continue
            }
            print("detected \(label.identifier) confidence \(label.confidence)")
            if label.confidence > confidenceThreshold {
                recognizedObjects.append(RecognizedObject(bounds: vnResult.boundingBox, label: label.identifier, confidence: label.confidence))
            }
        }
        completion?(recognizedObjects)
    }
    
    private var completion:(([RecognizedObject]) -> Void)?
    private let confidenceThreshold:Float = 0.8
    private var requests:[VNRequest] = []
}

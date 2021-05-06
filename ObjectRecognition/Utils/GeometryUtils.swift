//
//  GeometryUtils.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 27/04/21.
//

import Foundation
import UIKit

class GeometryUtils {
    static func boundingBox(forRecognizedRect: CGRect, imageFrame: CGRect) -> CGRect {
        var rect = forRecognizedRect
        
        rect.origin.x *= imageFrame.width
        rect.origin.y *= imageFrame.height
        rect.size.width *= imageFrame.width
        rect.size.height *= imageFrame.height

        // necessary as the recognized image is flipped vertically
        rect.origin.y = imageFrame.height - rect.origin.y - rect.size.height
        
        return rect
    }
    
    static func createRectLayerWithBounds(_ bounds: CGRect, color:CGColor) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.backgroundColor = color
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    static func createLayer(forRecognizedObjects objects:[RecognizedObject],
                            inFrame frame:CGRect) -> CALayer {
        let objectsLayer = CALayer()
        objectsLayer.frame = frame
        
        let color = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.4)
        
        for object in objects {
            let rect = GeometryUtils.boundingBox(forRecognizedRect: object.bounds,
                                                 imageFrame: frame)
            
            let layer = GeometryUtils.createRectLayerWithBounds(rect, color: color)

            let textLayer = GeometryUtils.createTextLayerWithBounds(layer.bounds,
                                                                    text: object.label)
            layer.addSublayer(textLayer)
            objectsLayer.addSublayer(layer)
        }
        
        return objectsLayer
    }
    
    static func createTextLayerWithBounds(_ bounds: CGRect, text: String) -> CATextLayer {
        let textLayer = CATextLayer()
        let formattedString = NSMutableAttributedString(string: text)
        let largeFont = UIFont(name: "Helvetica", size: 18.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: text.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // 2.0 for retina display
        return textLayer
    }
    
    /// works for sizeAspectFit
    static func imageFrameInView(imageSize:CGSize, viewSize:CGSize) -> CGRect {
        let widthRatio = imageSize.width / viewSize.width
        let heightRatio = imageSize.height / viewSize.height
        
        let ratio = max(widthRatio, heightRatio)
        
        let imageWidth = imageSize.width / ratio
        let imageHeight = imageSize.height / ratio
        
        let x = (viewSize.width - imageWidth) / 2
        let y = (viewSize.height - imageHeight) / 2
        
        return CGRect(x: x, y: y, width: imageWidth, height: imageHeight)
    }
    
    static func transformRect(_ bounds:CGRect,
                              forFrame frame:CGRect) -> CGRect {
        var returnFrame = CGRect(x: 0, y: 0, width:0, height: 0)
        var size = frame.size
        let orientation = UIDevice.current.orientation
        if  orientation == .portrait || orientation == .portraitUpsideDown {
            let tmp = size.width
            size.width = size.height
            size.height = tmp
        }
        returnFrame.origin.y = bounds.origin.x * size.width
        returnFrame.origin.x = bounds.origin.y * size.height
        returnFrame.size.width = bounds.size.width * size.width
        returnFrame.size.height = bounds.size.height * size.height
        return returnFrame
    }
    
    static func updateLayerGeometry(parentLayer: CALayer, size:CGSize, layerToUpdate:CALayer) {
        let bounds = parentLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / size.height
        let yScale: CGFloat = bounds.size.height / size.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        layerToUpdate.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 1.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        layerToUpdate.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    static private func updatePath(_ path:UIBezierPath?,
                                   withRect rect:CGRect) -> UIBezierPath {
        let updatedPath = path ?? UIBezierPath()
        updatedPath.move(to: rect.origin)
        updatedPath.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
        updatedPath.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        updatedPath.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        return updatedPath
    }
}

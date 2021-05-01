//
//  GeometryUtils.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 27/04/21.
//

import Foundation
import UIKit

class GeometryUtils {
    static func createRectLayerWithBounds(_ bounds: CGRect, color:CGColor) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.backgroundColor = color
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    static func createLayer(forRectangles rectangles:[CGRect],
                            transformRectangles:Bool,
                            frameSize:CGRect,
                            strokeColor:CGColor) -> CALayer {
        let layer = CAShapeLayer()
        layer.frame = frameSize
        
        var path = UIBezierPath()
        for rect in rectangles {
            if transformRectangles {
                let transformedRect = transformRect(rect, forFrame: frameSize)
                print("transformed rect \(transformedRect)")
                path = updatePath(path, withRect: transformedRect)
            }
            else {
                path = updatePath(path, withRect: rect)
            }
        }
        path.close()
        layer.path = path.cgPath
        layer.strokeColor = strokeColor
        layer.fillColor = UIColor.clear.cgColor
        
        return layer
    }
    
    static func createTextLayerWithBounds(_ bounds: CGRect, text: String) -> CATextLayer {
        let textLayer = CATextLayer()
        let formattedString = NSMutableAttributedString(string: text)
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: text.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // 2.0 for retina display
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 1.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    static func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let deviceOrientation = UIDevice.current.orientation
        let returnOrientation: CGImagePropertyOrientation
        
        switch deviceOrientation {
        case .portrait:
            returnOrientation = .right
        case .landscapeLeft:
            returnOrientation = .down
        case .landscapeRight:
            returnOrientation = .up
        case .portraitUpsideDown:
            returnOrientation = .left
        default:
            returnOrientation = .up
        }

        return returnOrientation
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

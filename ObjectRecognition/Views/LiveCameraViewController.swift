//
//  LiveCameraViewController.swift
//  ObjectRecognition
//
//  Created by Gualtiero Frigerio on 27/04/21.
//

import AVFoundation
import UIKit
import Vision

class LiveCameraViewController: UIViewController {
    
    required init() {
        self.cameraView = UIView()
        self.imageView = UIImageView()
        self.queue = DispatchQueue(label: "LiveCameraViewController")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = CGRect(x:0,
                                  y:0,
                                  width:view.frame.size.width,
                                  height: view.frame.size.height / 2) //self.view.frame
        cameraView.frame = self.view.frame
        view.addSubview(cameraView)
        imageView.frame = CGRect(x: 0,
                                 y: cameraView.frame.size.height,
                                 width: view.frame.size.width,
                                 height: view.frame.size.height / 2 )
        //view.addSubview(imageView)
        configureSession()
        configurePreview()
        session?.startRunning()
    }
    
    override func viewWillLayoutSubviews() {
        cameraView.frame = view.frame
        previewLayer?.frame = cameraView.layer.bounds
        previewLayer?.connection?.videoOrientation = OrientationUtils.videoOrientationForCurrentOrientation()
    }
    
    // MARK: - Private
    
    private var cameraView:UIView
    private var imageView:UIImageView
    private var isRecognizing = false
    private var objectRecognizer = ObjectRecognizer()
    private var objectsLayer:CALayer = CALayer()
    private var previewLayer:AVCaptureVideoPreviewLayer?
    private var queue:DispatchQueue
    private var session:AVCaptureSession?
    private var videoSize:CGSize = .zero
    
    /// Configure the preview layer
    /// the layer is added to the cameraView
    private func configurePreview() {
        guard let session = session else {return}
        if self.previewLayer == nil {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = cameraView.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
        }
    }
    
    private func configureSession() {
        let session = AVCaptureSession()
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera, .builtInTelephotoCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: .unspecified)
        
        guard let captureDevice = deviceDiscoverySession.devices.first,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
            session.canAddInput(videoDeviceInput)
            else { return }
        session.addInput(videoDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        
        session.addOutput(videoOutput)
        session.sessionPreset = .vga640x480
        
        let captureConnection = videoOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        
        let dimensions  = CMVideoFormatDescriptionGetDimensions((captureDevice.activeFormat.formatDescription))
        videoSize.width = CGFloat(dimensions.width)
        videoSize.height = CGFloat(dimensions.height)
        
        self.session = session
    }
    
    private func drawRecognizedObjects(_ objects:[RecognizedObject]) {
        guard let previewLayer = previewLayer else { return }

        objectsLayer = GeometryUtils.createLayer(forRecognizedObjects: objects,
                                              inFrame: previewLayer.frame)
        
        
        previewLayer.addSublayer(objectsLayer)
        previewLayer.setNeedsDisplay()
    }
    
    
}

extension LiveCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if isRecognizing {
            return
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext(options: nil)
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
            let image = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        objectsLayer.removeFromSuperlayer()
        isRecognizing = true
        
        objectRecognizer.recognize(fromPixelBuffer: pixelBuffer) { [weak self] objects in
            DispatchQueue.main.async {
                self?.drawRecognizedObjects(objects)
                self?.isRecognizing = false
            }
        }
    }
}

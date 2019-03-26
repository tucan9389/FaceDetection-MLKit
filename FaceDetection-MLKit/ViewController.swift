//
//  ViewController.swift
//  FaceDetection-MLKit
//
//  Created by Doyoung Gwak on 26/03/2019.
//  Copyright © 2019 Doyoung Gwak. All rights reserved.
//

import UIKit
import CoreMedia
import Firebase

class ViewController: UIViewController {

    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var emijiLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    // MARK - Inference Result Data
    //private var tableData: [BodyPoint?] = []
    
    // MARK - Performance Measurement Property
    private let 👨‍🔧 = 📏()
    
    // MARK: - ML Kit Vision Property
    lazy var vision = Vision.vision()
    lazy var faceDetector: VisionFaceDetector = { () -> VisionFaceDetector in
        // Real-time contour detection of multiple faces
        let options = VisionFaceDetectorOptions()
        options.contourMode = .all
        options.classificationMode = .all
        
        return vision.faceDetector(options: options)
    }()
    var isInference = false
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup camera
        setUpCamera()
        
        // setup drawing view
        drawingView.setUp()
        
        // setup delegate for performance measurement
        👨‍🔧.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    // MARK: - SetUp Video
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}

extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
        if !self.isInference, let pixelBuffer = pixelBuffer {
            // start of measure
            self.👨‍🔧.🎬👏()
            
            self.isInference = true
            
            // predict!
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}

extension ViewController {
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        let ciimage: CIImage = CIImage(cvImageBuffer: pixelBuffer)
        // crop found word
        let ciContext = CIContext()
        guard let cgImage: CGImage = ciContext.createCGImage(ciimage, from: ciimage.extent) else {
            self.isInference = false
            // end of measure
            self.👨‍🔧.🎬🤚()
            return
        }
        let uiImage: UIImage = UIImage(cgImage: cgImage)
        let visionImage = VisionImage(image: uiImage)
        faceDetector.process(visionImage) { (features, error) in
            self.👨‍🔧.🏷(with: "endInference")
            // this closure is called on main thread
            if error == nil, let faces: [VisionFace] = features {
                self.drawingView.imageSize = uiImage.size
                self.drawingView.faces = faces
                if (faces.first?.smilingProbability ?? 0) > 0.6 {
                    self.emijiLabel.text = "😆"
                } else {
                    self.emijiLabel.text = "🙂"
                }
                self.confidenceLabel.text = "Smiling Probability Estimation: \(String(format: "%.3f", faces.first?.smilingProbability ?? 0)) %"
            } else {
                self.drawingView.imageSize = .zero
                self.drawingView.faces = []
            }
            
             self.isInference = false
            // end of measure
            self.👨‍🔧.🎬🤚()
        }
    }
}

// MARK: - 📏(Performance Measurement) Delegate
extension ViewController: 📏Delegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        //print(executionTime, fps)
        self.inferenceLabel.text = "inference: \(Int(inferenceTime*1000.0)) mm"
        self.etimeLabel.text = "execution: \(Int(executionTime*1000.0)) mm"
        self.fpsLabel.text = "fps: \(fps)"
    }
}

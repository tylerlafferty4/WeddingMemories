//
//  CameraViewController.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 1/31/17.
//  Copyright © 2017 Tyler Lafferty. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // -- Outlets --
    @IBOutlet var previewView: UIView!
    @IBOutlet var countdownBtn: UIButton!
    @IBOutlet var captureBtn: UIButton!
    @IBOutlet var photoCapture: UIImageView!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var camImg: UIImageView!
    
    // -- Vars --
    var captureSesssion: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var capturedImage: UIImage!
    var secondsRemaining: Int = 10
    var timer: Timer! = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCapture.layer.cornerRadius = photoCapture.frame.width/2
        blurView.layer.cornerRadius = blurView.frame.width/2
        let tap = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.capturePhoto))
        camImg.isUserInteractionEnabled = true
        camImg.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset the countdown time
        secondsRemaining = 10
        countdownBtn.setTitle("\(secondsRemaining)", for: .normal)
        
        // Setup the camera session
        captureSesssion = AVCaptureSession()
        captureSesssion.sessionPreset = AVCaptureSessionPresetPhoto
        cameraOutput = AVCapturePhotoOutput()
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                if (captureSesssion.canAddOutput(cameraOutput)) {
                    captureSesssion.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer.frame = previewView.bounds
                    previewView.layer.addSublayer(previewLayer)
                    captureSesssion.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }

    }
}

// MARK: - Take Photo
extension CameraViewController {
    
    /// Timer button
    @IBAction func didPressTimer(_ sender: UIButton) {
        beginTimer()
    }
    
    /// Take picture button
    @IBAction func didPressTakePhoto(_ sender: UIButton) {
        capturePhoto()
    }
    
    /// Starts a timer
    func beginTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CameraViewController.countdownText), userInfo: nil, repeats: true)
    }
    
    /// Updates the countdown label
    func countdownText() {
        secondsRemaining -= 1
        countdownBtn.setTitle("\(secondsRemaining)", for: .normal)
        if secondsRemaining == 0 {
            timer.invalidate()
            capturePhoto()
        }
    }
    
    /// Captures the photo
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // callBack from take picture
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occured : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            capturedImage = image
            performSegue(withIdentifier: "showPreview", sender: self)
        } else {
            print("some error here")
        }
    }
}

// MARK: - Prepare for Segue
extension CameraViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PreviewViewController
        vc.takenPhoto = capturedImage
    }
}

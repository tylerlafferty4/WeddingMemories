//
//  CameraViewController.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 9/7/19.
//  Copyright © 2019 Tyler Lafferty. All rights reserved.
//

import Foundation
import AVFoundation
import Firebase

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // -- Outlets --
    @IBOutlet var previewView: UIView!
    @IBOutlet var countdownBtn: UIButton!
    @IBOutlet var countdownLbl: UILabel!
    @IBOutlet var captureBtn: UIButton!
    @IBOutlet var photoCapture: UIImageView!
    @IBOutlet var captureView: UIView!
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
        
        // Tap Gesture to take a picture
        let tap = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.showTap))
        camImg.isUserInteractionEnabled = true
        camImg.addGestureRecognizer(tap)
        camImg.image = UIImage(named: "camera-solid")?.withRenderingMode(.alwaysTemplate)
        camImg.tintColor = UIColor.lightGray
        countdownBtn.titleLabel?.numberOfLines = 0
        countdownBtn.titleLabel?.textAlignment = .center
        countdownBtn.setTitle("Start\nTimer", for: .normal)
        
        photoCapture.layer.cornerRadius = photoCapture.frame.width/2
        
        // Add shadows to the buttons
        captureView.layer.cornerRadius = captureView.frame.width/2
        captureView.layer.shadowColor = UIColor.black.cgColor
        captureView.layer.shadowOffset = CGSize(width: 0, height: 20)
        captureView.layer.shadowOpacity = 8
        captureView.layer.shadowRadius = 20
        
        // Timer Button
        countdownBtn.layer.masksToBounds = false
        countdownBtn.layer.cornerRadius = countdownBtn.frame.width/2
        countdownBtn.layer.shadowColor = UIColor.black.cgColor
        countdownBtn.layer.shadowOffset = CGSize(width: 0, height: 20)
        countdownBtn.layer.shadowOpacity = 8
        countdownBtn.layer.shadowRadius = 20
        
        // Timer Label
        countdownLbl.layer.cornerRadius = countdownLbl.frame.width/2
        countdownLbl.layer.shadowColor = UIColor.black.cgColor
        countdownLbl.layer.shadowOffset = CGSize(width: 0, height: 20)
        countdownLbl.layer.shadowOpacity = 8
        countdownLbl.layer.shadowRadius = 20
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset the countdown time
        secondsRemaining = 10
        countdownLbl.text = "\(secondsRemaining)"
        countdownBtn.isHidden = false
        countdownLbl.isHidden = true
        
        // Setup the camera session
        captureSesssion = AVCaptureSession()
        captureSesssion.sessionPreset = AVCaptureSession.Preset.photo
        cameraOutput = AVCapturePhotoOutput()
        
        #if targetEnvironment(simulator)
            self.capturedImage = UIImage(named: "Snapchat-1848010358")
            self.performSegue(withIdentifier: "showPreview", sender: self)
        #else
            let device = AVCaptureDevice.default(for: .video)
        
            if let input = try? AVCaptureDeviceInput(device: device!) {
                if (captureSesssion.canAddInput(input)) {
                    captureSesssion.addInput(input)
                    if (captureSesssion.canAddOutput(cameraOutput)) {
                        captureSesssion.addOutput(cameraOutput)
                        previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                        let bounds:CGRect = self.view.layer.bounds
                        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                        previewLayer?.bounds = bounds
                        previewLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY)
                        previewLayer.connection!.videoOrientation = .landscapeRight
                        previewView.layer.addSublayer(previewLayer)
                        captureSesssion.startRunning()
                    }
                } else {
                    print("This device does not have input")
                }
            } else {
                print("This device does not have a camera")
            }
        #endif
    }
    
    /// Top Button to dismiss the camera
    @IBAction func closeCamera(_ sender: UIButton) {
        // Make sure to turn the timer off
        if timer != nil {
            timer.invalidate()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Take Photo
extension CameraViewController {
    
    /// Timer button
    @IBAction func didPressTimer(_ sender: UIButton) {
        countdownBtn.isHidden = true
        countdownLbl.isHidden = false
        if let time = timer {
            // If the timer is running, don't start another one
            if time.isValid == false {
                beginTimer()
            }
        } else {
            // There is no timer going, start a new one
            beginTimer()
        }
    }
    
    /// Starts a timer
    func beginTimer() {
        // Every second, change the label text to simulate a countdown
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CameraViewController.countdownText), userInfo: nil, repeats: true)
    }
    
    /// Updates the countdown label
    @objc func countdownText() {
        secondsRemaining -= 1
        // Update the label to show how many seconds are remaining
        countdownLbl.text = "\(secondsRemaining)"
        // If the countdown is finished, stop the timer and take a photo
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
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let dataImg = photo.fileDataRepresentation() {
            let dataProvider = CGDataProvider(data: dataImg as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)

            let image = UIImage(cgImage: cgImageRef)//, scale: 1.0, orientation: nil)
            
            capturedImage = image
            performSegue(withIdentifier: "showPreview", sender: self)
        }
        
    }
    // callBack from take picture
//    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
//
//        if let error = error {
//            print("error occured : \(error.localizedDescription)")
//        }
//        if  let sampleBuffer = photoSampleBuffer,
//            let previewBuffer = previewPhotoSampleBuffer,
//            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
//            print(UIImage(data: dataImage)?.size as Any)
//
//            let dataProvider = CGDataProvider(data: dataImage as CFData)
//            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
//            //            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
//            let image = UIImage(cgImage: cgImageRef)//, scale: 1.0, orientation: nil)
//
//            capturedImage = image
//            performSegue(withIdentifier: "showPreview", sender: self)
//        } else {
//            print("Error Occurred trying to take a photo")
//        }
//    }
}

// MARK: - Helpers
extension CameraViewController {
    /// Shrinks and expands the view to show affordability
    @objc func showTap() {
        UIView.animate(withDuration: 0.2, animations: {
            self.photoCapture.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.captureView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (finished) in
            UIView.animate(withDuration: 0.2, animations: {
                self.photoCapture.transform = CGAffineTransform.identity
                self.captureView.transform = CGAffineTransform.identity
            }, completion: { (bool) in
                // The animation is complete, take a photo
                self.capturePhoto()
            })
            
        }
    }
}

// MARK: - Prepare for Segue
extension CameraViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PreviewViewController
        // Set the image so the user can Preview the image on the next page
        vc.takenPhoto = capturedImage
    }
}








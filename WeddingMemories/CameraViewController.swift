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
    
    var captureSesssion : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    var capturedImage: UIImageView!
    @IBOutlet weak var previewView: UIView!
    
    // Firebase Storage
    var storage = FIRStorage.storage()
    var storageRef = FIRStorageReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FireBase storage init
        storageRef = storage.reference(forURL: "gs://wedding-memories.appspot.com")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    // Take picture button
    @IBAction func didPressTakePhoto(_ sender: UIButton) {
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
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            capturedImage = UIImageView()
            capturedImage.image = image
            uploadToFirebase(img: image)
        } else {
            print("some error here")
        }
    }
    
    // This method you can use somewhere you need to know camera permission   state
    func askPermission() {
        print("here")
        let cameraPermissionStatus =  AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch cameraPermissionStatus {
        case .authorized:
            print("Already Authorized")
        case .denied:
            print("denied")
            
            let alert = UIAlertController(title: "Sorry :(" , message: "But  could you please grant permission for camera within device settings",  preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel,  handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        case .restricted:
            print("restricted")
        default:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {
                [weak self]
                (granted :Bool) -> Void in
                
                if granted == true {
                    // User granted
                    print("User granted")
                    DispatchQueue.main.async(){
                        //Do smth that you need in main thread
                    }
                }
                else {
                    // User Rejected
                    print("User Rejected")
                    
                    DispatchQueue.main.async(){
                        let alert = UIAlertController(title: "WHY?" , message:  "Camera it is the main feature of our application", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alert.addAction(action)
                        self?.present(alert, animated: true, completion: nil)  
                    } 
                }
            });
        }
    }
}

// MARK: - Upload to Firebase
extension CameraViewController {
    func uploadToFirebase(img : UIImage) {
        // Add the image as an attachment
        if let imgData: Data = UIImagePNGRepresentation(img) {
            print("Image converted to Data")
            
            // Create a reference to the file you want to upload
            let riversRef = self.storageRef.child("images/test.jpg")//\(WMShared.sharedInstance.emailAddress).jpg")
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.put(imgData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("******An Error Occurred******")
//                    self.displayFailedAlert()
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                print(downloadURL)
            }
            
            // Check the progress of the upload
            let observer = uploadTask.observe(.progress) { snapshot in
                // A progress event occured
            }
//            self.displaySentAlert()
        }
    }
}

//
//  PreviewViewController.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 9/7/19.
//  Copyright © 2019 Tyler Lafferty. All rights reserved.
//

import Foundation
import Firebase
import MessageUI

class PreviewViewController: UIViewController {
    
    // -- Outlets --
    @IBOutlet var previewImgView: UIImageView!
    @IBOutlet var usePhotoBtn: UIButton!
    @IBOutlet var retakeBtn: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var activityInd: UIActivityIndicatorView!
    @IBOutlet var loadPercent: UILabel!
    @IBOutlet var sendChoices: UIView!
    @IBOutlet var viewProg: UIView! // your parent view, Just a blank view
    
    // -- Vars --
    var choicesShown: Bool = false
    var viewCornerRadius : CGFloat = 5
    var borderLayer : CAShapeLayer = CAShapeLayer()
    var progressLayer : CAShapeLayer = CAShapeLayer()
    
    // -- Blur View --
    var blur: UIVisualEffectView!
    
    // -- Set from other controller --
    var takenPhoto: UIImage!
    
    // -- Firebase Storage --
    var storage = Storage.storage()
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FireBase storage init
        storageRef = storage.reference()
        
        // Set the preview to image that was taken
        previewImgView.image = takenPhoto
        
        // Add Tap gesture to image view to dismiss choices
        let tap = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.touchedView))
        previewImgView.addGestureRecognizer(tap)
        
        sendChoices.layer.cornerRadius = viewCornerRadius
        sendChoices.layer.shadowColor = UIColor.black.cgColor
        sendChoices.layer.shadowOffset = CGSize(width: 0, height: 20)
        sendChoices.layer.shadowOpacity = 8
        sendChoices.layer.shadowRadius = 20
        
        // Set the image view for the buttons
        usePhotoBtn.imageView?.contentMode = .scaleAspectFit
        let image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
        usePhotoBtn.setImage(image, for: .normal)
        usePhotoBtn.imageView?.tintColor = UIColor.green
        retakeBtn.imageView?.contentMode = .scaleAspectFit
        
        loadingView.layer.cornerRadius = viewCornerRadius
        viewProg.layer.cornerRadius = viewCornerRadius
        
        // Initial draw of the progress view
        drawProgressLayer()
        
        // Detect faces
        detect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Button Actions
extension PreviewViewController {
    @IBAction func usePhoto(_ sender: Any) {
        // If the choices are already shown, dismiss. Else display the choices
        if choicesShown == false {
            showChoices()
        } else {
            hideChoices()
        }
    }
    
    @IBAction func retakePhoto(_ sender: Any) {
        // Pop back to the camera view
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Chose email destination
    @IBAction func sendToEmail(_ sender: Any) {
        // Hide the choices prompt
        hideChoices()
        // Ask the user for their email
        promptForEmail()
    }
    
    /// Chose phone destination
    @IBAction func sendToPhone(_ sender: Any) {
        // Hide the choices prompt
        hideChoices()
        // Ask the user for their phone number
        promptForPhoneNumber()
    }
}

// MARK: - Firebase Upload
extension PreviewViewController {
    
    /// Uploads the image to FireBase
    func uploadPhoto() {
        // Add the image as an attachment
        if let imgData: Data = takenPhoto.pngData() {
            
            // Create an image name to use
            let imageName = "\(getUniqueFileName())"
            
            // Create a reference to the file you want to upload
            let imageRef = storageRef.child("\(WMShared.sharedInstance.brideGroom)/\(imageName)")
            
            // Show the loader to the user
            self.unhideLoader()
            
            // Upload the file
            let uploadTask = imageRef.putData(imgData, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    print("******An Error Occurred******")
                    
                    // Hide the loader
                    self.hideLoader()
                    
                    // Display failed message
                    self.displayFailedAlert()
                    return
                }
                
                // Metadata contains file metadata such as size, content-type, and download URL.
                //                let downloadURL = metadata.downloadURL
                
                // Append to images array in order to use on screen saver now
                WMShared.sharedInstance.imageNames.append(imageName)
                
                // Save the image to the device for use on the screen saver
                self.addImageToDocuments(img: self.takenPhoto, name: imageName)
                
                // Hide the loading view upon completion
                self.hideLoader()
                
                // Image has been uploaded. Display the success alert
                self.displaySentAlert()
            }
            
            // Track the progress of the upload
            _ = uploadTask.observe(.progress) { snapshot in
                // A progress event occured
                print("Progress -> \(String(describing: snapshot.progress))")
                
                // Update the label with the percent complete
                let percentComplete = 100 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                let rounded = Int(percentComplete.rounded())
                self.loadPercent.text = "\(rounded)%"
                
                // Update the progress bar
                let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                let prog = progress * Double(self.viewProg.bounds.width - 10)
                self.rectProgress(incremented: CGFloat(prog))
            }
        } else {
            // Uh-oh, an error occurred!
            print("******An Error Occurred******")
            
            // Hide the loader
            self.hideLoader()
            
            // Display failed message
            self.displayFailedAlert()
        }
    }
}

// MARK: - Custom Alets
extension PreviewViewController {
    
    /// Call this method to ask the user for their email address
    func promptForEmail() {
        let emailAlert = CustomAlertView()
        let confirm = CustomAlertAction(title: "Upload") {
            // Email has been entered, begin upload of file
            self.sendEmail(toEmail: WMShared.sharedInstance.userContact, withImg: self.takenPhoto.pngData()!)
            self.uploadPhoto()
        }
        let cancel = CustomAlertAction(title: "Cancel") {
            
        }
        emailAlert.showAlertView(superview: self.view, title: "Please enter your email address", text: "example@gmail.com", type: .Email, img: nil, confirmAction: confirm, cancelAction: cancel)
    }
    
    /// Call this method to ask the user for their phone number
    func promptForPhoneNumber() {
        let emailAlert = CustomAlertView()
        let confirm = CustomAlertAction(title: "Upload") {
            // Phone Number has been entered, begin upload of file
            self.uploadPhoto()
        }
        let cancel = CustomAlertAction(title: "Cancel") {
            
        }
        emailAlert.showAlertView(superview: self.view, title: "Please enter your phone number", text: "Phone Number", type: .PhoneNumber, img: nil, confirmAction: confirm, cancelAction: cancel)
    }
    
    /// Call this method after the photo has been uploaded
    func displaySentAlert() {
        let sentAlert = CustomAlertView()
        let confirm = CustomAlertAction(title: "OK") {
            self.dismiss(animated: true, completion: nil)
        }
        sentAlert.showAlertView(superview: self.view, title: "Wedding Memories", text: "Thank you for using Wedding Memories. Your photo will be sent shortly", type: .Text, img: "checkmark", confirmAction: confirm)
    }
    
    /// Call this method an error occurs while uploading the photo
    func displayFailedAlert() {
        let failAlert = CustomAlertView()
        let confirm = CustomAlertAction(title: "Try Again") {
            self.uploadPhoto()
        }
        failAlert.showAlertView(superview: self.view, title: "Wedding Memories", text: "Sorry, something went wrong. Please try again", type: .Text, img: "X", confirmAction: confirm)
    }
}

// MARK: - MFMailComposer
extension PreviewViewController: MFMailComposeViewControllerDelegate {
    func sendEmail(toEmail email : String, withImg img : Data) {
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([email])
            mailComposeViewController.setSubject("Wedding Memories Photo")
            mailComposeViewController.setMessageBody("Thank you for using Wedding Memories to help \(WMShared.sharedInstance.brideGroom) remember their special day.", isHTML: false)
            mailComposeViewController.addAttachmentData(img, mimeType: "image/png", fileName: "Image.png")
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            print("Unable to send mail")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Helpers
extension PreviewViewController {
    
    /// Add the image to the device documents
    func addImageToDocuments(img : UIImage, name : String) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(name).jpg")
        let image = self.takenPhoto
        let imageData = image?.jpegData(compressionQuality: 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    /// Used to display the choices popup
    @objc func touchedView() {
        if choicesShown == true {
            hideChoices()
        }
    }
    
    /// Add blur view for loading view
    func addBlurView() {
        blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = self.view.frame
        self.view.addSubview(blur)
    }
    
    
    /// Hide the blur view
    func hideBlurView() {
        blur.removeFromSuperview()
    }
    
    /// Prompts the user for email or phone number sending
    func showChoices() {
        choicesShown = true
        UIView.animate(withDuration: 0.3) {
            self.sendChoices.isHidden = false
            self.sendChoices.alpha = 1
        }
    }
    
    /// Hides the choices of how to send the image
    func hideChoices() {
        choicesShown = false
        UIView.animate(withDuration: 0.3) {
            self.sendChoices.isHidden = true
            self.sendChoices.alpha = 0
        }
    }
    
    /// Unhides the progress view
    func unhideLoader() {
        addBlurView()
        self.view.bringSubviewToFront(loadingView)
        activityInd.startAnimating()
        retakeBtn.isUserInteractionEnabled = false
        usePhotoBtn.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.loadingView.isHidden = false
            self.loadingView.alpha = 1
        }
    }
    
    /// Hides the progress view
    func hideLoader() {
        hideBlurView()
        activityInd.stopAnimating()
        retakeBtn.isUserInteractionEnabled = true
        usePhotoBtn.isUserInteractionEnabled = true
        self.loadingView.isHidden = true
        self.loadingView.alpha = 0
    }
    
    /// Returns a unique file name for saving to Firebase
    func getUniqueFileName() -> String {
        let uuid = UUID().uuidString
        let fileName = "\(uuid).png"
        return fileName
    }
    
    /// Initial draw of the progress view
    func drawProgressLayer(){
        let bezierPath = UIBezierPath(roundedRect: viewProg.bounds, cornerRadius: viewCornerRadius)
        bezierPath.close()
        borderLayer.path = bezierPath.cgPath
        borderLayer.fillColor = UIColor.black.cgColor
        borderLayer.strokeEnd = 0
        viewProg.layer.addSublayer(borderLayer)
        viewProg.bringSubviewToFront(loadPercent)
    }
    
    //Make sure the value that you want in the function `rectProgress` that is going to define
    //the width of your progress bar must be in the range of
    // 0 <--> viewProg.bounds.width - 10 , reason why to keep the layer inside the view with some border left spare.
    //if you are receiving your progress values in 0.00 -- 1.00 range , just multiply your progress values to viewProg.bounds.width - 10 and send them as *incremented:* parameter in this funcs
    func rectProgress(incremented : CGFloat){
        print(incremented)
        if incremented <= viewProg.bounds.width - 10{
            progressLayer.removeFromSuperlayer()
            let bezierPathProg = UIBezierPath(roundedRect: CGRect(x: 5, y: 5, width: incremented, height: viewProg.bounds.height-10 ), cornerRadius: viewCornerRadius)
            bezierPathProg.close()
            progressLayer.path = bezierPathProg.cgPath
            progressLayer.fillColor = UIColor.green.cgColor
            borderLayer.addSublayer(progressLayer)
        }
    }
}


// MARK: - Facial Recognition
extension PreviewViewController {
    func detect() {
//        let ciImage  = CIImage(cgImage: previewImgView.image!.cgImage!)
//        let ciDetector = CIDetector(ofType:CIDetectorTypeFace
//            ,context:CIContext()
//            ,options:[
//                CIDetectorAccuracy:CIDetectorAccuracyHigh,
//                CIDetectorSmile:true
//            ]
//        )
//
//        let features = ciDetector?.features(in: ciImage, options: [CIDetectorImageOrientation:1])
//
//        UIGraphicsBeginImageContext(previewImgView.image!.size)
//        previewImgView.image!.draw(in: CGRect(x: 0, y: 0, width: previewImgView.image!.size.width, height: previewImgView.image!.size.height))
//
//        for feature in features! {
//
//            //context
//            let drawCtxt = UIGraphicsGetCurrentContext()
//
//            // Face
//            let face = feature as! CIFaceFeature
//
//            //            //face
//            //            var faceRect = face.bounds
//            //            faceRect.origin.y = previewImgView.image!.size.height - faceRect.origin.y - faceRect.size.height
//            //            drawCtxt!.setStrokeColor(UIColor.red.cgColor)
//            //            drawCtxt!.stroke(faceRect)
//            //
//            //            //mouth
//            //            if face.hasMouthPosition != false{
//            //                let mouseRectY = previewImgView.image!.size.height - face.mouthPosition.y
//            //                let mouseRect  = CGRect(x: face.mouthPosition.x - 5, y: mouseRectY - 5, width: 10, height: 10)
//            //                drawCtxt!.setStrokeColor(UIColor.blue.cgColor)
//            //                drawCtxt!.stroke(mouseRect)
//            //            }
//            //
//            //            MustacheHandler.drawFrenchMustache(imgView: previewImgView, face: face, context: drawCtxt!)
//
//            MustacheHandler.drawFullBeard(imgView: previewImgView, face: face, context: drawCtxt!)
//
//            HatHandler.drawTopHat(imgView: previewImgView, face: face, context: drawCtxt!)
//
//            //            GlassesHandler.drawSunglasses(imgView: previewImgView, face: face, context: drawCtxt!)
//
//            //            //leftEye
//            //            if(feature as! CIFaceFeature).hasLeftEyePosition != false{
//            //                let leftEyeRectY = previewImgView.image!.size.height - (feature as! CIFaceFeature).leftEyePosition.y
//            //                let leftEyeRect  = CGRect(x:(feature as! CIFaceFeature).leftEyePosition.x - 5,y:leftEyeRectY - 5,width:10,height:10)
//            //                drawCtxt!.setStrokeColor(UIColor.blue.cgColor)
//            //                drawCtxt!.stroke(leftEyeRect)
//            //            }
//            //
//            //            //rightEye
//            //            if (feature as! CIFaceFeature).hasRightEyePosition != false{
//            //                let rightEyeRectY = previewImgView.image!.size.height - (feature as! CIFaceFeature).rightEyePosition.y
//            //                let rightEyeRect  = CGRect(x:(feature as! CIFaceFeature).rightEyePosition.x - 5,y:rightEyeRectY - 5,width:10,height:10)
//            //                drawCtxt!.setStrokeColor(UIColor.blue.cgColor)
//            //                drawCtxt!.stroke(rightEyeRect)
//            //            }
//        }
//        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        previewImgView.image = drawnImage
//        self.takenPhoto = drawnImage
    }
}














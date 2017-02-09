//
//  PreviewViewController.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 2/2/17.
//  Copyright © 2017 Tyler Lafferty. All rights reserved.
//

import Foundation
import Firebase

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
    
    var choicesShown: Bool = false
    
    let viewCornerRadius : CGFloat = 5
    var borderLayer : CAShapeLayer = CAShapeLayer()
    let progressLayer : CAShapeLayer = CAShapeLayer()
    
    // -- Blur View --
    var blur: UIVisualEffectView!
    
    // -- Set from other controller --
    var takenPhoto: UIImage!
    
    // -- Firebase Storage --
    var storage = FIRStorage.storage()
    var storageRef = FIRStorageReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FireBase storage init
        storageRef = storage.reference(forURL: "gs://wedding-memories.appspot.com")
        
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
        drawProgressLayer()
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
        if choicesShown == false {
            showChoices()
        } else {
            hideChoices()
        }
    }
    
    @IBAction func retakePhoto(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendToEmail(_ sender: Any) {
        hideChoices()
        promptForEmail()
    }
    
    @IBAction func sendToPhone(_ sender: Any) {
        hideChoices()
        promptForPhoneNumber()
    }
}

// MARK: - Firebase Upload
extension PreviewViewController {
    
    /// Uploads the image to FireBase
    func uploadPhoto() {
        // Add the image as an attachment
        if let imgData: Data = UIImagePNGRepresentation(takenPhoto) {
            
            // Create an image name to use
            let imageName = "\(getUniqueFileName())"
            
            // Create a reference to the file you want to upload
            let imageRef = storageRef.child("\(WMShared.sharedInstance.brideGroom)/\(imageName)")
            
            // Show the loader to the user
            self.unhideLoader()
            
            // Upload the file 
            let uploadTask = imageRef.put(imgData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
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
                print("Progress -> \(snapshot.progress)")
                
                // Update the label with the percent complete
                let percentComplete = 100 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                let rounded = Int(percentComplete.rounded())
                self.loadPercent.text = "\(rounded)%"
                
                // Update the progress bar
                let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                let prog = progress * Double(self.viewProg.bounds.width - 10)
                self.rectProgress(incremented: CGFloat(prog))
            }
        }
    }
}

// MARK: - Custom Alets 
extension PreviewViewController {
    
    /// Call this method to ask the user for their email address
    func promptForEmail() {
        let emailAlert = CustomAlertView()
        let confirm = CustomAlertAction(title: "Upload") {
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

// MARK: - Helpers
extension PreviewViewController {
    
    /// Add the image to the device documents
    func addImageToDocuments(img : UIImage, name : String) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(name).jpg")
        let image = self.takenPhoto
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    /// Used to display the choices popup
    func touchedView() {
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
        self.view.bringSubview(toFront: loadingView)
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
        let fileName = "\(WMShared.sharedInstance.userContact)-\(uuid)"
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
        viewProg.bringSubview(toFront: loadPercent)
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















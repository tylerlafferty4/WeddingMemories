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
    
    @IBOutlet var viewProg: UIView! // your parent view, Just a blank view
    
    
    let viewCornerRadius : CGFloat = 5
    var borderLayer : CAShapeLayer = CAShapeLayer()
    let progressLayer : CAShapeLayer = CAShapeLayer()

    
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
        
        // Set the image view for the buttons
        usePhotoBtn.imageView?.contentMode = .scaleAspectFit
        retakeBtn.imageView?.contentMode = .scaleAspectFit
        
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
        promptForEmail()
    }
    
    @IBAction func retakePhoto(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Firebase Upload
extension PreviewViewController {
    func uploadPhoto() {
        // Add the image as an attachment
        if let imgData: Data = UIImagePNGRepresentation(takenPhoto) {
            print("Image converted to Data")
            
            // Create a reference to the file you want to upload
            let imageRef = storageRef.child("images/\(getUniqueFileName()).jpg")
            
            // Upload the file 
            let uploadTask = imageRef.put(imgData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("******An Error Occurred******")
                    
                    // Display failed message
                    self.displayFailedAlert()
                    return
                }
                
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                print(downloadURL)
                self.hideLoader()
                self.displaySentAlert()
            }
            
            // Track the progress of the upload
            _ = uploadTask.observe(.progress) { snapshot in
                // A progress event occured
                print("Progress -> \(snapshot.progress)")
                
                // Show the loader to the user
                self.unhideLoader()
                
                // Update the label with the percent complete
                let percentComplete = 100 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                let rounded = percentComplete.rounded()
                self.loadPercent.text = "\(rounded)%"
                
                // Update the progress bar
                let progress = CGFloat(snapshot.progress!.completedUnitCount/snapshot.progress!.totalUnitCount)
                let prog = progress * self.viewProg.bounds.width - 10
                self.rectProgress(incremented: prog)
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
        emailAlert.showAlertView(superview: self.view, title: "Please enter your email address", text: "Please enter your email address", type: .Email, img: nil, confirmAction: confirm, cancelAction: cancel)
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
    
    /// Unhides the progress view
    func unhideLoader() {
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
    
    func drawProgressLayer(){
        let bezierPath = UIBezierPath(roundedRect: viewProg.bounds, cornerRadius: viewCornerRadius)
        bezierPath.close()
        borderLayer.path = bezierPath.cgPath
        borderLayer.fillColor = UIColor.black.cgColor
        borderLayer.strokeEnd = 0
        viewProg.layer.addSublayer(borderLayer)
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
            progressLayer.fillColor = UIColor.white.cgColor
            borderLayer.addSublayer(progressLayer)
        }
    }
}















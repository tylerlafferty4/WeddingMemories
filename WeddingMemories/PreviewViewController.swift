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
            let imageRef = self.storageRef.child("images/\(WMShared.sharedInstance.userContact).jpg")
            
            // Upload the file to the path "images/rivers.jpg"
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
                self.displaySentAlert()
            }
            // Check the progress of the upload
            _ = uploadTask.observe(.progress) { snapshot in
                // A progress event occured
                print("Progress -> \(snapshot.progress)")
            }
            
            // Picture has been uploaded. Display confirmation
            
        }
    }
}

// MARK: - Custom Alets 
extension PreviewViewController {
    
    /// Call this method to ask the user for their email address
    func promptForEmail() {
        let emailAlert = CustomAlertView()
        let confirm = CustomAlertAction(title: "Send") {
            self.uploadPhoto()
        }
        emailAlert.showAlertView(superview: self.view, title: "Please enter your email address", text: "Please enter your email address", type: .TextField, img: nil, confirmAction: confirm)
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

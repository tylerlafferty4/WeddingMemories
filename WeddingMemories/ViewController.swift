//
//  ViewController.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 1/24/17.
//  Copyright © 2017 Tyler Lafferty. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class ViewController: UIViewController, UINavigationControllerDelegate {

    
    // -- Outlets --
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var photoBtn: UIButton!
    @IBOutlet var circleView: UIView!
    
    // Camera
    var imagePicker: UIImagePickerController!
    var takenPhoto: UIImage!
    
    // Firebase Storage
    var storage = FIRStorage.storage()
    var storageRef = FIRStorageReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circleView.layer.masksToBounds = false
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOffset = CGSize(width: 0, height: 20)
        circleView.layer.shadowOpacity = 8
        circleView.layer.shadowRadius = 20
        
        imgView.layer.cornerRadius = imgView.frame.width/2
        
        storageRef = storage.reference(forURL: "gs://wedding-memories.appspot.com")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Photo Button
extension ViewController {
    @IBAction func takePhoto(sender: UIButton) {
//        imagePicker =  UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .camera
//        
//        present(imagePicker, animated: true, completion: nil)
        performSegue(withIdentifier: "showCamera", sender: self)    
    }
}

// MARK: - Email
extension ViewController : MFMailComposeViewControllerDelegate {
    
    func displayEmailField() {
        let alert = CustomAlertView()
        let confirm = CustomAlertAction(title: "Send") {
            
            // Add the image as an attachment
            if let imgData: Data = UIImagePNGRepresentation(self.takenPhoto) {
                print("Image converted to Data")
                
                // Create a reference to the file you want to upload
                let riversRef = self.storageRef.child("images/\(WMShared.sharedInstance.emailAddress).jpg")
                
                // Upload the file to the path "images/rivers.jpg"
                let uploadTask = riversRef.put(imgData, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print("******An Error Occurred******")
                        self.displayFailedAlert()
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
                self.displaySentAlert()
            }
        }
        alert.showAlertView(superview: self.view, title: "Send an Email", text: "Please enter your email address", img: nil, confirmAction: confirm, cancelAction: nil)
    }
}

// MARK: - Alerts
extension ViewController {
    func displaySentAlert() {
        let sentAlert = CustomAlertView()
        sentAlert.showAlertView(superview: self.view, title: "Wedding Memories", text: "Thank you for using Wedding Memories. Your photo will be sent shortly")
    }
    
    func displayFailedAlert() {
        let failAlert = CustomAlertView()
        failAlert.showAlertView(superview: self.view, title: "Wedding Memories", text: "Sorry, something went wrong. Please try again")
    }
}

// MARK: - UIImagePickerViewController Delegate
extension ViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        takenPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        dismiss(animated:true, completion: nil) //5
        displayEmailField()
    }
}

// MARK: - Prepare for segue
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}


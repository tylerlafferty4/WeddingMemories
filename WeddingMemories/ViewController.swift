//
//  ViewController.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 1/24/17.
//  Copyright © 2017 Tyler Lafferty. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, UINavigationControllerDelegate {

    
    // -- Outlets --
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var photoBtn: UIButton!
    @IBOutlet var circleView: UIView!
    
    // Camera
    var imagePicker: UIImagePickerController!
    var takenPhoto: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circleView.layer.masksToBounds = false
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOffset = CGSize(width: 0, height: 20)
        circleView.layer.shadowOpacity = 8
        circleView.layer.shadowRadius = 20
        
        imgView.layer.cornerRadius = imgView.frame.width/2
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Photo Button
extension ViewController {
    @IBAction func takePhoto(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - Email
extension ViewController : MFMailComposeViewControllerDelegate {
    
    func displayEmailField() {
        let alert = CustomAlertView()
        let confirm = CustomAlertAction(title: "Send") {
            print("Sending email to \(WMShared.sharedInstance.emailAddress)")
            
            let mailViewController = MFMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                print("Can print")
            }
            mailViewController.mailComposeDelegate = self
            mailViewController.setSubject("Goose and Berta Wedding Memories")
            mailViewController.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
            // Set the TO Recipient to the entered email
            mailViewController.setToRecipients([WMShared.sharedInstance.emailAddress])
            
            // Add the image as an attachment
            if let imgData: Data = UIImagePNGRepresentation(self.takenPhoto) {
                print("Image converted to Data")
                mailViewController.addAttachmentData(imgData as Data, mimeType: "png", fileName: "\(WMShared.sharedInstance.emailAddress) Wedding Memory")
            }
            
            self.present(mailViewController, animated: true, completion: nil)
        }
        alert.showAlertView(superview: self.view, title: "Send an Email", text: "Please enter your email address", img: nil, confirmAction: confirm, cancelAction: nil)
    }
    
    private func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Email was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed:
            print("Email failed")
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent:
            print("Email was sent")
            self.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved:
            print("Email was saved")
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Alerts
extension ViewController {
    func displaySentAlert() {
        
    }
    
    func displayFailedAlert() {
        
    }
}

// MARK: - UIImagePickerViewController Delegate
extension ViewController : UIImagePickerControllerDelegate {
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        takenPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        dismiss(animated:true, completion: nil) //5
        displayEmailField()
    }
}


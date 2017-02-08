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
    @IBOutlet var backgroundView: UIImageView!
    
    // -- Vars --
    var timer: Timer! = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding Shadows and rounded corners
        circleView.layer.masksToBounds = false
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOffset = CGSize(width: 0, height: 20)
        circleView.layer.shadowOpacity = 8
        circleView.layer.shadowRadius = 20
        imgView.layer.cornerRadius = imgView.frame.width/2
        
        // Add a special gesture if the user taps on the circle image
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.showTap))
        imgView.addGestureRecognizer(tap)
        
        // Add Gesture to allow camera to display no matter where a user taps
        let backTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.showCamera))
        backgroundView.addGestureRecognizer(backTap)
        
        // Get an array of image names that are stored in Documents directory
        getImageNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If we have images to display on screen saver, start a inactivity timer to then display the screen saver
        if WMShared.sharedInstance.imageNames.count > 0 {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.displayScreenSaver), userInfo: nil, repeats: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Brings up the screensaver view
    func displayScreenSaver() {
        self.performSegue(withIdentifier: "showScreensaver", sender: self)
    }
    
    /// Get a list of all the image names that are stored in the Documents
    func getImageNames(){
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            // if you want to filter the directory contents you can do like this:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "jpg" }
            WMShared.sharedInstance.imageNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Photo Button
extension ViewController {
    
    /// Display the camera to the user
    @IBAction func takePhoto(sender: UIButton) {
        showCamera()
    }
}

// MARK: - Prepare for segue
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

// MARK: - Helpers
extension ViewController {
    
    /// Display the camera
    func showCamera() {
        if timer != nil {
            timer.invalidate()
        }
        performSegue(withIdentifier: "showCamera", sender: self)
    }
    
    /// Animate the circle image view to show affordability
    func showTap() {
        UIView.animate(withDuration: 0.2, animations: {
            self.imgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.circleView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (finished) in
            UIView.animate(withDuration: 0.2, animations: {
                self.imgView.transform = CGAffineTransform.identity
                self.circleView.transform = CGAffineTransform.identity
            }, completion: { (bool) in
                self.showCamera()
            })
        
        }
    }
}

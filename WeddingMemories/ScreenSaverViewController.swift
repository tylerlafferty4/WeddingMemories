//
//  ScreenSaverViewController.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 9/7/19.
//  Copyright © 2019 Tyler Lafferty. All rights reserved.
//

import Foundation
import UIKit

class ScreenSaverViewController: UIViewController {
    
    // -- Outlets --
    @IBOutlet var screenSaver: UIImageView!
    
    // -- Vars --
    var timer: Timer! = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tap Gesture added to whole screen to dismiss the screen saver
        let tap = UITapGestureRecognizer(target: self, action: #selector(ScreenSaverViewController.dismissScreenSaver))
        screenSaver.addGestureRecognizer(tap)
    }
    
    /// Dismiss the screen saver
    @objc func dismissScreenSaver() {
        screenSaver.layer.removeAllAnimations()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the screen saver
        displayScreenSaver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /// Cycles through images that have been taken and displays them for 5 seconds each
    func displayScreenSaver() {
        
        // We can't show an index that we don't have. Reset to 0 if the index gets too large
        if WMShared.sharedInstance.imageNames.count <= WMShared.sharedInstance.screenSaverIndex {
            WMShared.sharedInstance.screenSaverIndex = 0
        }
        
        // Determine what the next image will be to display
        let toImage = findImage(name: WMShared.sharedInstance.imageNames[WMShared.sharedInstance.screenSaverIndex])
        
        // Start the animation to change to image
        CATransaction.begin()
        
        // How long the fade will last
        CATransaction.setAnimationDuration(2)
        
        // Once the animation completes, wait 5 seconds and then run this function again
        CATransaction.setCompletionBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + SCREEN_SAVER_SLIDE_TIME) {
                // Increment our index to get the next image
                WMShared.sharedInstance.screenSaverIndex += 1
                self.displayScreenSaver()
            }
        }
        
        // Add the animation to the image view
        let transition = CATransition()
        transition.type = CATransitionType.fade
        screenSaver.layer.add(transition, forKey: kCATransition)
        screenSaver.image = toImage
        CATransaction.commit()
    }
    
    /// Pulls back a UIImage for the path
    func findImage(name: String) -> UIImage {
        let fileManager = FileManager.default
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("\(name).jpg")
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        } else {
            let secondPath = "\(imagePath).jpg"
            if fileManager.fileExists(atPath: secondPath) {
                return UIImage(contentsOfFile: imagePath)!
            } else {
                let thirdPath = (self.getDirectoryPath() as NSString).appendingPathComponent(name)
                if fileManager.fileExists(atPath: thirdPath) {
                    return UIImage(contentsOfFile: imagePath)!
                } else {
                    print("No Image")
                    return UIImage()
                }
            }
        }
    }
    
    /// Gets the documents directory path
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

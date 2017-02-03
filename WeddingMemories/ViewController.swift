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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circleView.layer.masksToBounds = false
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOffset = CGSize(width: 0, height: 20)
        circleView.layer.shadowOpacity = 8
        circleView.layer.shadowRadius = 20
        
        imgView.layer.cornerRadius = imgView.frame.width/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Photo Button
extension ViewController {
    @IBAction func takePhoto(sender: UIButton) {
        performSegue(withIdentifier: "showCamera", sender: self)    
    }
}

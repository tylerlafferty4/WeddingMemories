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
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.showTap))
        imgView.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Photo Button
extension ViewController {
    @IBAction func takePhoto(sender: UIButton) {
        showCamera()
    }
}

// MARK: - Helpers
extension ViewController {
    
    func showCamera() {
        performSegue(withIdentifier: "showCamera", sender: self)
    }
    
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

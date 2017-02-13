//
//  GlassesHandler.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 2/11/17.
//  Copyright © 2017 Tyler Lafferty. All rights reserved.
//

import Foundation
import UIKit

class GlassesHandler {
    
    class func drawSunglasses(imgView : UIImageView, face : CIFaceFeature, context : CGContext) {
        let faceRect = face.bounds
        var glasses = UIImage(named: "sunglasses")
        let imgWidth = faceRect.size.width 
        let imgHeight = imgWidth * 0.3
        
        // Create the X & Y point for the mustache
        let glassesY = imgView.image!.size.height - face.leftEyePosition.y - (imgHeight/2)
        var glassesX = face.leftEyePosition.x - imgWidth/2.7
        
//        if face.faceAngle < 0 {
//            glassesX -= CGFloat(abs(face.faceAngle))
//        } else {
//            glassesX += CGFloat(face.faceAngle)
//        }
        
        // Create the rect to draw it in
        let imgRect = CGRect(x: glassesX, y: glassesY, width: imgWidth, height: imgHeight)
        
        // Rotate the image according to the face angle
        glasses = glasses?.rotated(by: Measurement(value: Double(face.faceAngle), unit: .degrees))
        
        // Draw the mustache on
        glasses?.draw(in: imgRect)
    }
}

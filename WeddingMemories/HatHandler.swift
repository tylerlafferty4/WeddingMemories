//
//  HatHandler.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 2/10/17.
//  Copyright © 2017 Tyler Lafferty. All rights reserved.
//

import Foundation
import UIKit

class HatHandler {
    
    /// Add a top hat to someone
    class func drawTopHat(imgView : UIImageView, face : CIFaceFeature, context : CGContext) {
        let faceRect = face.bounds
        var hat = UIImage(named: "Top-hat")
        let imgWidth = faceRect.size.width*1.4
        let imgHeight = faceRect.size.height
        let hatY = imgView.image!.size.height - faceRect.origin.y-(imgHeight * 1.8)
        var hatX = face.mouthPosition.x - imgWidth/2.3
        if face.faceAngle < 0 {
            hatX -= CGFloat(abs(face.faceAngle))
        } else {
            hatX += CGFloat(face.faceAngle)
        }
        let imgRect = CGRect(x: hatX, y: hatY, width: imgWidth, height: imgHeight)
        hat = hat?.rotated(by: Measurement(value: Double(face.faceAngle), unit: .degrees))
        hat?.draw(in: imgRect)
    }
}

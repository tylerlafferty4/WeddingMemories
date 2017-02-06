//
//  WMShared.swift
//  WeddingMemories
//
//  Created by Tyler Lafferty on 1/25/17.
//  Copyright © 2017 Tyler Lafferty. All rights reserved.
//

import Foundation

class WMShared {
    
    static var sharedInstance: WMShared! = WMShared()
    var userContact: String = ""
}

extension String {
    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    // Validate PhoneNumber
    var isPhoneNumber: Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
}

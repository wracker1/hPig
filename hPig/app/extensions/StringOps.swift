//
//  StringOps.swift
//  hPig
//
//  Created by Jesse on 2016. 11. 18..
//  Copyright © 2016년 wearespeakingtube. All rights reserved.
//

import Foundation

extension String {
    func r() -> NSRegularExpression {
        return try! NSRegularExpression(pattern: self, options: .caseInsensitive)
    }
    
    func range() -> NSRange {
        return NSRange(location: 0, length: self.characters.count)
    }
    
    func substring(range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
    
    func localized(_ comment: String? = nil) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment ?? "")
    }
    
    func isValidateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: self)
    }
    
    func attributedString(with pattern: String) -> NSMutableAttributedString {
        let results = matchesInStringWithRegex(pattern, string: self)
        let attributedString = NSMutableAttributedString(string: self)
        
        results.forEach { (result) in
            let range = result.rangeAt(0)
            
            attributedString.addAttributes([NSForegroundColorAttributeName: secondPointColor],
                                           range: NSRange(location: range.location, length: range.length))
        }
        
        return attributedString
    }

    private func matchesInStringWithRegex(_ regex: String, string: String) -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            return regex.matches(in: string, options: .reportProgress, range: NSMakeRange(0, string.characters.count))
        } catch {
            print(error)
            return []
        }
    }
}

//
//  Extensions.swift
//  StudentManagement
//
//  Created by Zubair.Nagori on 11/10/18.
//  Copyright © 2018 joseph. All rights reserved.
//

import Foundation

extension UIViewController {
    func presentAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension Date {
    func toString() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm:a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
    
    func isInPast() -> Bool {
        if self.timeIntervalSinceNow < 0.0 {
            return true
        }
        
        return false
    }
}

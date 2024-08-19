//
//  ExtensionViewController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import UIKit

extension UIViewController {
    
    /// Show alert
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alertVC, animated: true)
        }
    }
    
    /// Save context
    func saveContexts() {
        do {
            try CoreDataController.shared.viewContext.save()
        } catch {
            // Try again 2 seconds
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
                self.saveContexts()
            }
        }
    }
    
    /// Decode unicode character of steam content
    func decodeUnicodeEscapeSequences(_ string: String) -> String? {
        let pattern = #"\\u([0-9A-Fa-f]{4})"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let nsString = string as NSString
        let matches = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var decodedString = string
        matches?.reversed().forEach { match in
            if let range = Range(match.range(at: 1), in: string) {
                let hexCode = String(string[range])
                if let scalar = UnicodeScalar(Int(hexCode, radix: 16)!) {
                    decodedString = (decodedString as NSString).replacingCharacters(in: match.range, with: String(scalar))
                }
            }
        }
        
        return decodedString
    }
}

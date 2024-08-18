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
            DispatchQueue.global(qos: .background).async {
                // Force try again
                self.saveContexts()
            }
        }
    }
}

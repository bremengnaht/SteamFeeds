//
//  FavoritedFeedsViewController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import UIKit

class FavoritedFeedsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SteamAPIService.getAppList { result in
            switch result {
            case .success(let appListRes):
                print("Get App List Success")
                break
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
                break
            }
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

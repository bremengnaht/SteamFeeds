//
//  FavoritedAppTableViewCell.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import UIKit

class FavoritedAppTableViewCell: UITableViewCell {

    @IBOutlet weak var applicationName: UILabel!
    @IBOutlet weak var subscribeSince: UILabel!
    var steamApp: SteamApp! = nil
}

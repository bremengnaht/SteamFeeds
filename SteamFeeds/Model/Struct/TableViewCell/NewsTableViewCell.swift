//
//  NewsTableViewCell.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 18/8/24.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var feedLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var createDate: UILabel!

    var news: News! = nil

}

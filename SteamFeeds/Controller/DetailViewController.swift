//
//  DetailViewController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 18/8/24.
//

import UIKit
import WebKit
import SafariServices

class DetailViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var news: News!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWebViewContent()
        navigationBar.title = news.title
    }
    
    func updateWebViewContent() {
        guard let content = news.content else { return }
        
        let htmlString = """
<html>
<body>
<font size="7">
\(content.replacingOccurrences(of: "\n", with: "<br>"))
</font>
</body>
</html>
"""
        if let decodedString = decodeUnicodeEscapeSequences(htmlString) {
            webView.loadHTMLString(decodedString, baseURL: nil)
        }
    }
    
    @IBAction func openExternalURL(_ sender: Any) {
        if let url = URL(string: news.url!) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
}

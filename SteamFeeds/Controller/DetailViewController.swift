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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var news: News!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = news.title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateWebViewContent()
    }
    
    func updateWebViewContent() {
        // Bring the decode processing to the background
        DispatchQueue.global(qos: .userInteractive).async {
            guard let content = self.news.content else { return }
            let htmlString = """
                <html>
                    <body>
                        <font size="7">
                            \(content.replacingOccurrences(of: "\n", with: "<br>"))
                        </font>
                    </body>
                </html>
            """
            if let decodedString = self.decodeUnicodeEscapeSequences(htmlString) {
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(decodedString, baseURL: nil)
                    self.activityIndicatorView.stopAnimating()
                }
            }
        }
    }
    
    @IBAction func openExternalURL(_ sender: Any) {
        if let url = URL(string: news.url!) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
}

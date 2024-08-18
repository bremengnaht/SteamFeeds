//
//  NewsViewController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 18/8/24.
//

import UIKit
import CoreData

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var steamApp: SteamApp!
    var newsFetchedResultController: NSFetchedResultsController<News>!
    var news: [News] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        fetchNewsFromCoreData()
        getLatestNewsFromAPI()
    }
    
    func toggleControllersOnMainThread(isDownloadingNews: Bool) {
        DispatchQueue.main.async {
            if isDownloadingNews {
                self.activityIndicatorView.startAnimating()
            } else {
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func refreshTableOnMainThread() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegueIndentifier" {
            let destination = segue.destination as! DetailViewController
            destination.news = (sender as! News)
        }
    }

}

// MARK: - UITableView

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCellReuseIdentifier", for: indexPath) as! NewsTableViewCell

        let data = news[indexPath.row]
        cell.news = data
//        cell.applicationName.text = data.appName
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        cell.subscribeSince.text = "Subscribe since \(dateFormatter.string(from: data.favoriteDate!))"
        
        let newSelectionBackground = UIView()
        newSelectionBackground.backgroundColor = .systemBlue
        cell.selectedBackgroundView = newSelectionBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailSegueIndentifier", sender: news[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
    
}

// MARK: - Core Data

extension NewsViewController: NSFetchedResultsControllerDelegate {
    
    func fetchNewsFromCoreData() {
        let fetchRequest: NSFetchRequest<News> = News.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "unixTime", ascending: false)
        let predicate = NSPredicate(format: "steamApp == %@", steamApp)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        newsFetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        newsFetchedResultController.delegate = self
        do {
            try newsFetchedResultController.performFetch()
            guard let fetchedObjects = newsFetchedResultController.fetchedObjects else { fatalError("Unable to fetch from persistent container") }
            news = fetchedObjects
            refreshTableOnMainThread()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        guard let fetchedObjects = controller.fetchedObjects else { fatalError("Unable to fetch from persistent container") }
        news = fetchedObjects as! [News]
        refreshTableOnMainThread()
    }
    
}

// MARK: - Steam API

extension NewsViewController {
    func getLatestNewsFromAPI() {
        DispatchQueue.global(qos: .utility).async {
            self.toggleControllersOnMainThread(isDownloadingNews: true)
//            SteamAPIService.getAppList { result in
//                self.getAppListCompletionHandler(result)
//            }
        }
    }
    
//    func getAppListCompletionHandler(_ result: Result<APIResponseGetAppList, any Error>) {
//        switch result {
//        case let .success(appListRes):
//            if let appList = appListRes.appList?.apps {
//                for app in appList {
//                    // App with no name will be removed
//                    if app.name == "" { continue }
//                    
//                    let newApp = SteamApp(context: CoreDataController.shared.viewContext)
//                    newApp.appId = app.appId
//                    newApp.appName = app.name
//                    newApp.isFavorited = false
//                }
//                self.toggleControllersOnMainThread(isDownloadingNews: false)
//                self.saveContexts()
//            } else {
//                self.toggleControllersOnMainThread(isDownloadingNews: false)
//                self.showAlert(title: "Error", message: "Something wrong with Steam's API. Please fetch again from Setting OR restart the app!")
//            }
//            break
//        case .failure(let error):
//            self.toggleControllersOnMainThread(isDownloadingNews: false)
//            self.showAlert(title: "Error", message: error.localizedDescription)
//            break
//        }
//    }
}

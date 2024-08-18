//
//  FavoritedAppsViewController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import UIKit
import CoreData

class FavoritedAppsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var settingButton: UIBarButtonItem!
    @IBOutlet weak var addNewFavoriteApp: UIBarButtonItem!
    @IBOutlet weak var favoritedAppTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var favoritedAppsFetchedResultController: NSFetchedResultsController<SteamApp>!
    var favoritedApp: [SteamApp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritedAppTableView.dataSource = self
        favoritedAppTableView.delegate = self
        
        fetchFavoritedAppFromCoreData()
        checkIsFirstTime()
    }
    
    @IBAction func openSetting(_ sender: Any) {
        performSegue(withIdentifier: "settingSegueIndentifier", sender: nil)
    }
    
    func toggleControllers(isDownloadingAllApp: Bool) {
        DispatchQueue.main.async {
            self.settingButton.isEnabled = !isDownloadingAllApp
            self.addNewFavoriteApp.isEnabled = !isDownloadingAllApp
            if isDownloadingAllApp {
                self.activityIndicatorView.startAnimating()
            } else {
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func refreshTable() {
        DispatchQueue.main.async {
            self.favoritedAppTableView.reloadData()
        }
    }
}

// MARK: - UITableView

extension FavoritedAppsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritedApp.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritedTableViewCellReuseId", for: indexPath) as! FavoritedAppTableViewCell
        
        let data = favoritedApp[indexPath.row]
        cell.steamApp = data
        cell.applicationName.text = data.appName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.subscribeSince.text = "Subscribe since \(dateFormatter.string(from: data.favoriteDate!))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewDetailSegueIndentifier", sender: favoritedApp[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let customButton = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            // TODO: Implement delete context
        }
        customButton.backgroundColor = .red
        customButton.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [customButton])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

// MARK: - Core Data

extension FavoritedAppsViewController: NSFetchedResultsControllerDelegate {
    
    func fetchFavoritedAppFromCoreData() {
        let fetchRequest: NSFetchRequest<SteamApp> = SteamApp.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "favoriteDate", ascending: false)
        let predicate = NSPredicate(format: "isFavorited == %d", true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        favoritedAppsFetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        favoritedAppsFetchedResultController.delegate = self
        do {
            try favoritedAppsFetchedResultController.performFetch()
            refreshTable()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func checkIsFirstTime() {
        let fetchRequest: NSFetchRequest<SteamApp> = SteamApp.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "appId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let allAppFetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try allAppFetchedResultController.performFetch()
            guard let appList = allAppFetchedResultController.fetchedObjects else {
                fatalError("Unable to fetch from persistent container")
            }
            if appList.isEmpty {
                getAppListFromSteamAPI()
            } else {
                toggleControllers(isDownloadingAllApp: false)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        guard let fetchedObjects = controller.fetchedObjects else { return }
        
        favoritedApp = fetchedObjects as! [SteamApp]
        favoritedAppTableView.reloadData()
    }
    
}

// MARK: - Steam API

extension FavoritedAppsViewController {
    
    func getAppListFromSteamAPI() {
        toggleControllers(isDownloadingAllApp: true)
        SteamAPIService.getAppList { result in
            switch result {
            case let .success(appListRes):
                if let appList = appListRes.appList?.apps {
                    for app in appList {
                        // App with no name will be removed
                        if app.name == "" { continue }
                        
                        let newApp = SteamApp(context: CoreDataController.shared.viewContext)
                        newApp.appId = app.appId
                        
                        // TODO: MOCK ONLY (remove later)
                        newApp.isFavorited = true
                        newApp.favoriteDate = Date()
                        // TODO: END MOCK ONLY
                        
                        newApp.appName = app.name
                    }
                    self.saveContexts()
                } else {
                    self.showAlert(title: "Error", message: "Something wrong with Steam's API. Please fetch again from Setting OR restart the app!")
                }
                break
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
                break
            }
            self.toggleControllers(isDownloadingAllApp: false)
        }
    }
}

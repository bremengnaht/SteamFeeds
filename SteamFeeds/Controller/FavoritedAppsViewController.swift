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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            self.favoritedAppTableView.isHidden = isDownloadingAllApp
            self.activityIndicatorView.isHidden = !isDownloadingAllApp
        }
    }
    
    func refreshTableOnMainThread() {
        DispatchQueue.main.async {
            self.favoritedAppTableView.reloadData()
        }
    }
}

// MARK: - UITableView

extension FavoritedAppsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchedObjects = favoritedAppsFetchedResultController.fetchedObjects {
            return fetchedObjects.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritedTableViewCellReuseId", for: indexPath) as! FavoritedAppTableViewCell
        
        let data = favoritedAppsFetchedResultController.fetchedObjects![indexPath.row]
        cell.steamApp = data
        cell.applicationName.text = data.appName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.subscribeSince.text = "Subscribe since \(dateFormatter.string(from: data.favoriteDate!))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewDetailSegueIndentifier", sender: favoritedAppsFetchedResultController.fetchedObjects![indexPath.row])
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
            refreshTableOnMainThread()
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
                        let newApp = SteamApp(context: CoreDataController.shared.viewContext)
                        newApp.appId = app.appId
                        
                        // TODO: MOCK ONLY (remove later)
                        newApp.isFavorited = true
                        newApp.favoriteDate = Date()
                        // TODO: END MOCK ONLY
                        
                        newApp.appName = app.name
                    }
                    self.saveContexts()
                    self.toggleControllers(isDownloadingAllApp: false)
                    self.refreshTableOnMainThread()
                } else {
                    self.showAlert(title: "Error", message: "Something wrong with Steam's API. Please fetch again from Setting OR restart the app!")
                    self.toggleControllers(isDownloadingAllApp: false)
                }
                break
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
                self.toggleControllers(isDownloadingAllApp: false)
                break
            }
        }
    }
}

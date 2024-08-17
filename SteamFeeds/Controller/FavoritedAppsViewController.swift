//
//  FavoritedAppsViewController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import UIKit
import CoreData

class FavoritedAppsViewController: UIViewController {
    @IBOutlet weak var settingButton: UIBarButtonItem!
    @IBOutlet weak var addNewFavoriteApp: UIBarButtonItem!
    @IBOutlet weak var favortedAppTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var favoritedAppsFetchedResultController: NSFetchedResultsController<SteamApp>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIsFirstTime()
        fetchFavoritedAppFromCoreData()
    }
    
    func toggleControllers(isDownloadingAllApp: Bool) {
        DispatchQueue.main.async {
            self.settingButton.isEnabled = !isDownloadingAllApp
            self.addNewFavoriteApp.isEnabled = !isDownloadingAllApp
            self.favortedAppTableView.isHidden = isDownloadingAllApp
            self.activityIndicatorView.isHidden = !isDownloadingAllApp
        }
    }
}

// MARK: - Core Data

extension FavoritedAppsViewController: NSFetchedResultsControllerDelegate {
    
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
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func saveContexts() {
        do {
            try CoreDataController.shared.viewContext.save()
        } catch {
            showAlert(title: "Error", message: "Failed to save item(s): \(error)")
            fatalError("Failed to save item(s): \(error)")
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
                        newApp.isFavorited = false
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

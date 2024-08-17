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
    
    var favoritedAppsFetchedResultController: NSFetchedResultsController<SteamApp>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIsFirstTime()
        fetchFavoritedAppFromCoreData()
        
    }
    
    func toggleControllers(isDownloadingAllApp: Bool) {
        settingButton.isEnabled = !isDownloadingAllApp
        addNewFavoriteApp.isEnabled = !isDownloadingAllApp
        favortedAppTableView.isHidden = isDownloadingAllApp
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
        let predicate = NSPredicate(format: "isFavorited == %@", true)
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

// MARK: - Steam APIs

extension FavoritedAppsViewController {
    
    func getAppListFromSteamAPI() {
        toggleControllers(isDownloadingAllApp: true)
        SteamAPIService.getAppList { result in
            switch result {
            case .success(let appListRes):
                print("Get App List Success")
                break
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
                break
            }
            self.toggleControllers(isDownloadingAllApp: false)
        }
    }
}

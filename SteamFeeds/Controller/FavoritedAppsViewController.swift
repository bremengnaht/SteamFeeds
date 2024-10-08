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
    @IBOutlet weak var favoritedAppTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var placeholderView: UIView!
    
    var favoritedAppsFetchedResultController: NSFetchedResultsController<SteamApp>!
    var favoritedApp: [SteamApp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritedAppTableView.dataSource = self
        favoritedAppTableView.delegate = self
        
        fetchFavoritedAppFromCoreData()
    }
    
    @IBAction func openSetting(_ sender: Any) {
        performSegue(withIdentifier: "settingSegueIndentifier", sender: nil)
    }
    
    @IBAction func openAddNewApp(_ sender: Any) {
        performSegue(withIdentifier: "newFavoriteSegueIndentifier", sender: nil)
    }
    
    func toggleControllersOnMainThread(isDownloadingAllApp: Bool) {
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
    
    func refreshTableOnMainThread() {
        DispatchQueue.main.async {
            self.favoritedAppTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsViewSegueIndentifier" {
            let destination = segue.destination as! NewsViewController
            destination.steamApp = (sender as! SteamApp)
        }
    }
}

// MARK: - UITableView

extension FavoritedAppsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        placeholderView.isHidden = favoritedApp.count != 0
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
        
        let newSelectionBackground = UIView()
        newSelectionBackground.backgroundColor = .systemBlue
        cell.selectedBackgroundView = newSelectionBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "newsViewSegueIndentifier", sender: favoritedApp[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let customButton = UIContextualAction(style: .destructive, title: "") { (action, view, _) in
            self.favoritedAppTableView.performBatchUpdates({
                self.favoritedApp.remove(at: indexPath.row)
                self.favoritedAppTableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: { _ in
                guard let fetchedObjects = self.favoritedAppsFetchedResultController.fetchedObjects else { fatalError("Unable to fetch from persistent container") }
                let app = fetchedObjects[indexPath.row]
                app.favoriteDate = nil
                app.isFavorited = false
                self.saveContexts()
            })
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
        let sortDescriptor = NSSortDescriptor(key: "favoriteDate", ascending: true)
        let predicate = NSPredicate(format: "isFavorited == %d", true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        favoritedAppsFetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        favoritedAppsFetchedResultController.delegate = self
        do {
            try favoritedAppsFetchedResultController.performFetch()
            guard let fetchedObjects = favoritedAppsFetchedResultController.fetchedObjects else { fatalError("Unable to fetch from persistent container") }
            if fetchedObjects.isEmpty {
                checkOutTheEntireSteamAppList()
            } else {
                favoritedApp = fetchedObjects
            }
            refreshTableOnMainThread()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func checkOutTheEntireSteamAppList() {
        let fetchRequest: NSFetchRequest<SteamApp> = SteamApp.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "appId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let allAppFetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try allAppFetchedResultController.performFetch()
            guard let appList = allAppFetchedResultController.fetchedObjects else { fatalError("Unable to fetch from persistent container") }
            if appList.isEmpty {
                getAppListFromSteamAPI()
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        guard let fetchedObjects = controller.fetchedObjects else { fatalError("Unable to fetch from persistent container") }
        favoritedApp = fetchedObjects as! [SteamApp]
        refreshTableOnMainThread()
    }
    
}

// MARK: - Steam API

extension FavoritedAppsViewController {
    
    func getAppListFromSteamAPI() {
        DispatchQueue.global(qos: .utility).async {
            self.toggleControllersOnMainThread(isDownloadingAllApp: true)
            SteamAPIService.getAppList { result in
                self.getAppListCompletionHandler(result)
            }
        }
    }
    
    func getAppListCompletionHandler(_ result: Result<APIResponseGetAppList, any Error>) {
        switch result {
        case let .success(appListRes):
            if let appList = appListRes.appList?.apps {
                for app in appList {
                    // App with no name will be removed
                    if app.name == "" { continue }
                    
                    let newApp = SteamApp(context: CoreDataController.shared.viewContext)
                    newApp.appId = app.appId
                    newApp.appName = app.name
                    newApp.isFavorited = false
                }
                self.toggleControllersOnMainThread(isDownloadingAllApp: false)
                self.saveContexts()
            } else {
                self.toggleControllersOnMainThread(isDownloadingAllApp: false)
                self.showAlert(title: "Error", message: "Something wrong with Steam's API. Please fetch again from Setting OR restart the app!")
            }
            break
        case .failure(let error):
            self.toggleControllersOnMainThread(isDownloadingAllApp: false)
            self.showAlert(title: "Error", message: error.localizedDescription)
            break
        }
    }
}

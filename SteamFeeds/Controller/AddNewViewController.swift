//
//  AddNewViewController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 18/8/24.
//

import UIKit
import CoreData

class AddNewViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var steamApps: [SteamApp] = []
    var currentSearchResult: [SteamApp] = []
    var searchWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        fetchAllAppFromCoreData()
    }
}

// MARK: - UITableView

extension AddNewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentSearchResult.count == 0 {
            return 1
        }
        
        return currentSearchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentSearchResult.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyCellReuseId", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCellReuseId", for: indexPath) as! AddNewTableViewCell
        
        let data = currentSearchResult[indexPath.row]
        cell.steamApp = data
        cell.applicationName.text = data.appName
        
        let newSelectionBackground = UIView()
        newSelectionBackground.backgroundColor = .systemBlue
        cell.selectedBackgroundView = newSelectionBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentSearchResult.count == 0 { return }
        
        let selectedRow = currentSearchResult[indexPath.row]
        if selectedRow.isFavorited {
            showAlert(title: "Ug uh !!!", message: "This game is already favorited")
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        selectedRow.isFavorited = true
        selectedRow.favoriteDate = Date()
        saveContexts()
        self.dismiss(animated: true)
    }
    
}

// MARK: - UISearchBar

extension AddNewViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cancel the previous work item if it exists
        searchWorkItem?.cancel()
        // Create a new work item with the debounced task
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(with: searchText)
        }
        // Store the new work item and execute it after a delay
        searchWorkItem = workItem
        // 0.5 second debounce
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    private func performSearch(with query: String) {
        if query != "" {
            self.currentSearchResult = self.steamApps.filter({ app in
                if let appName = app.appName {
                    return appName.lowercased().contains(query.lowercased())
                }
                return false
            })
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - Core Data

extension AddNewViewController {
    
    func fetchAllAppFromCoreData() {
        let fetchRequest: NSFetchRequest<SteamApp> = SteamApp.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "appName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let allAppFetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try allAppFetchedResultController.performFetch()
            guard let appList = allAppFetchedResultController.fetchedObjects else { fatalError("Unable to fetch from persistent container") }
            self.steamApps = appList
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}

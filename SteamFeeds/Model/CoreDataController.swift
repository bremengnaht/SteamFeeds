//
//  CoreDataController.swift
//  SteamFeeds
//
//  Created by Thang Nguyen on 17/8/24.
//

import Foundation
import CoreData

class CoreDataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static let shared: CoreDataController = CoreDataController(modelName: "SteamFeeds")
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> ())? = nil ) {
        persistentContainer.loadPersistentStores { (storesDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}

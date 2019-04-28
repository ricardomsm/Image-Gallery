//
//  SizeManager.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 27/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit
import CoreData

class SizeManager {
    
    static let shared = SizeManager()
    let appDelegate   = UIApplication.shared.delegate as? AppDelegate
    let context       = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func saveSize(_ size: Size, andImage image: NSData) {
        
        guard let context = context else { print("Error getting context"); return }
        let entity        = SizeManagedObject(entity: SizeManagedObject.entity(), insertInto: context)
        
        entity.id     = size.id
        entity.label  = size.label
        entity.width  = size.width
        entity.height = size.width
        entity.source = size.source
        entity.url    = size.url
        entity.media  = size.media
        entity.image  = image
        
        appDelegate?.saveContext()
    }
    
    func deleteAll(_ entity: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            guard let results = try context?.fetch(fetchRequest) else { print("Error getting results"); return }
            
            print("Fetch Results: \(results.count)")
            if results.count == 0 {
                return
            }
            
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context?.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
        
        appDelegate?.saveContext()
    }
}

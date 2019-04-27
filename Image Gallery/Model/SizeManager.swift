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
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func saveSize(_ size: Size, andImage image: NSData) {
        
        let container = appDelegate?.persistentContainer
        let context   = container?.viewContext
        let entity    = SizeManagedObject(context: context!)
        
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
}

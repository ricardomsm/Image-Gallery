//
//  SizeMapper.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 27/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import Foundation

class SizeMapper: NSObject {
    
    func size(fromManagedObject managedObject: SizeManagedObject) -> Size {
        
        var size    = Size(withDictionary: nil)
        size.id     = managedObject.id
        size.label  = managedObject.label
        size.width  = managedObject.width
        size.height = managedObject.height
        size.source = managedObject.source
        size.url    = managedObject.url
        size.media  = managedObject.media
        size.image  = managedObject.image
        
        return size
    }
}

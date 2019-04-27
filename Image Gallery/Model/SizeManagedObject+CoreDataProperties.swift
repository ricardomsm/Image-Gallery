//
//  SizeManagedObject+CoreDataProperties.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 26/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//
//

import Foundation
import CoreData


extension SizeManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SizeManagedObject> {
        return NSFetchRequest<SizeManagedObject>(entityName: "SizeManagedObject")
    }

    @NSManaged public var label: String?
    @NSManaged public var width: String?
    @NSManaged public var height: String?
    @NSManaged public var source: String?
    @NSManaged public var url: String?
    @NSManaged public var media: String?
    @NSManaged public var image: NSData?

}

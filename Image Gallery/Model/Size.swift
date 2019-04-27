//
//  Size.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 25/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import Foundation

struct Size {
    var id     : String?
    var label  : String?
    var width  : String?
    var height : String?
    var source : String?
    var url    : String?
    var media  : String?
    var image  : NSData?
    
    init(withDictionary dictionary: [String : Any]?) {
        
        guard let dictionary = dictionary else { print("Error getting dictionary"); return }
        
        id     = ""
        label  = dictionary["label"] as? String
        width  = dictionary["width"] as? String
        height = dictionary["height"] as? String
        source = dictionary["source"] as? String
        url    = dictionary["url"] as? String
        media  = dictionary["media"] as? String
    }
    
    mutating func assignId(withId id: String) {
        self.id = id
    }
}

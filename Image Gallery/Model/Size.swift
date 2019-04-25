//
//  Size.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 25/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import Foundation

struct Size {
    var label  : String?
    var width  : Int?
    var height : Int?
    var source : String?
    var url    : String?
    var media  : String?
    
    init(withDictionary dictionary: [String : Any]?) {
        
        guard let dictionary = dictionary else { print("Error getting dictionary"); return }
        
        label  = dictionary["label"] as? String
        width  = dictionary["width"] as? Int
        height = dictionary["height"] as? Int
        source = dictionary["source"] as? String
        url    = dictionary["url"] as? String
        media  = dictionary["media"] as? String
    }
}

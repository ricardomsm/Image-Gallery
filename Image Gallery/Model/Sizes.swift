//
//  Sizes.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 25/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import Foundation

struct Sizes {
    var canDownload : Bool?
    var size        : [Size]?
    
    init(withDictionary dictionary: [String : Any]?) {
        
        guard let dictionary = dictionary else { print("Error getting dictionary"); return }
        
        canDownload = dictionary["candownload"] as? Bool
        size        = parseSizeArray(withArray: dictionary["size"] as? [[String : Any]])
    }
    
    private func parseSizeArray(withArray jsonArray: [[String : Any]]?) -> [Size] {
        
        var sizeArray = [Size]()
        
        if let array = jsonArray {
            
            for size in array {
                
                let size = Size(withDictionary: size)
                sizeArray.append(size)
            }
        }
        
        return sizeArray
    }
}

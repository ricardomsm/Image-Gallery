//
//  SearchSizeResponse.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 25/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import Foundation

struct SearchSizeResponse {
    var sizes : Sizes?
    var stat  : String?
    
    init(withDictionary dictionary: [String : Any]?) {
        
        guard let dictionary = dictionary else { print("error getting dictionary"); return }
        
        sizes = Sizes(withDictionary: dictionary["sizes"] as? [String : Any])
        stat  = dictionary["stat"] as? String
    }
}

//
//  SearchPhotosResponse.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 25/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import Foundation

struct SearchPhotosResponse: Codable {
    
    var photos : Photos?
    var stat   : String?
}

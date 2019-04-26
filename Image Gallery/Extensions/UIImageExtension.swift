//
//  UIImageExtension.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 26/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func downloadImageFromUrl(_ url: URL, returns: @escaping (_ image: UIImage) -> Void) {

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print(error)
                Alert.showGeneralAlert(withMessage: error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            guard let image = UIImage(data: data) else { print("Couldn't get image"); return }
            returns(image)
            
        }.resume()
    }
}

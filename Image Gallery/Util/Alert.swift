//
//  Alert.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 26/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit

struct Alert {
    
    private static var alert = UIAlertController()
    
    static func showGeneralAlert(withMessage message: String) {
        
        DispatchQueue.main.async {
            alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    static func showLoadingIndicatorAlert(onView view: UIViewController) {
        
        alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        view.present(alert, animated: true, completion: nil)
    }
    
    static func dismissLoadingIndicator() {
        alert.dismiss(animated: true, completion: nil)
    }
    
}

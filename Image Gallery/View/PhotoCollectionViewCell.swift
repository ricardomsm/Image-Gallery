//
//  PhotoCollectionViewCell.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 24/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var imageView : UIImageView!
    var imageUrl  = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addImageView()
    }
    
    private func addImageView() {
        
        if imageView == nil {
            
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            imageView.contentMode = .scaleAspectFill
            self.addSubview(imageView)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addImageView()
    }
    
}

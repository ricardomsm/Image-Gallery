//
//  ImageGalleryContract.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 27/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit

protocol ImageGalleryViewModelProtocol {
    func fetchImages(withText text: String?)
    func getImage(withUrl imageUrl: String, for cell: PhotoCollectionViewCell)
    func showLargeImage(forIndexPath indexPath: IndexPath)
    func fetchLargeImageUrlFor(indexPath: IndexPath)
    func displayImage(withUrl url: String)
    func beginBatchFetch()
}

protocol ImageGalleryViewControllerProtocol {
    func setImages()
    func setImageOnCell(_ cell: PhotoCollectionViewCell, withImage image: UIImage)
    func setLargeImage(withImage image: UIImage)
}

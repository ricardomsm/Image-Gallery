//
//  ImageGalleryViewModel.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 27/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit

class ImageGalleryViewModel: ImageGalleryViewModelProtocol {
    
    //MARK: - Variables and constructor
    var view                 : ImageGalleryViewControllerProtocol?
    
    lazy var sizeArray       = [Size]()
    lazy var tilesArray      = [Size]()
    lazy var largeImageArray = [Size]()
    lazy var imageCache      = NSCache<NSString, UIImage>()
    lazy var currentPage     = 1
    lazy var totalPages      = 0
    var isFetchingMore       = false
    var lastUserEnteredText  = ""
    
    init(withView view: ImageGalleryViewController) {
        self.view = view
    }
    
    //MARK: - View Model Methods
    func fetchImages(withText text: String?) {
        
        if let text = text {
            lastUserEnteredText = text
        }
        
        if isFetchingMore && currentPage <= totalPages {
            currentPage += 1
        } else {
            currentPage = 1
        }
        
        APIService.shared.fetchImages(withText: text, page: currentPage, success: { sizeArray, totalPages in
            
            self.totalPages = totalPages

            self.sizeArray.append(contentsOf: sizeArray)
            self.tilesArray.append(contentsOf: sizeArray.filter({ $0.label == "Large Square" }))
            self.largeImageArray.append(contentsOf: sizeArray.filter({ $0.label == "Large" }))
            
            self.view?.setImages()
            
            if self.isFetchingMore {
                self.isFetchingMore = false
                DispatchQueue.main.async {
                    Alert.dismissLoadingIndicator()
                }
            }
            
        }) { error in
            print(error)
        }
    }
    
    func beginBatchFetch() {
        isFetchingMore = true
        fetchImages(withText: lastUserEnteredText)
    }
    
    func getImage(withUrl imageUrl: String, for cell: PhotoCollectionViewCell) {
        
        DispatchQueue.global(qos: .background).async {
            
            guard let url = URL(string: imageUrl) else { print("Error getting url"); return }
            
            UIImage.downloadImageFromUrl(url, returns: { image in
                
                if let image = image {
                    
                    self.imageCache.setObject(image, forKey: NSString(string: imageUrl))
                    
                    if cell.imageUrl == imageUrl {
                        self.view?.setImageOnCell(cell, withImage: image)
                    }
                } else {
                    self.getImage(withUrl: imageUrl, for: cell)
                }
            })
        }
    }
    
    func showLargeImage(forIndexPath indexPath: IndexPath) {
        
        guard let view = self.view as? ImageGalleryViewController else { return }
        
        /*
         Here we check if the user has scrolled down fast enough,
         that didn't allow time for the fetching all the large images,
         so we fetch them on the go
         */
        if indexPath.row >= self.largeImageArray.count || self.tilesArray[indexPath.row].id != self.largeImageArray[indexPath.row].id {
            
            Alert.showLoadingIndicatorAlert(onView: view)
            fetchLargeImageUrlFor(indexPath: indexPath)
        } else {

            let largeImage = self.largeImageArray.filter({ $0.id == self.tilesArray[indexPath.row].id }).first

            if let url = largeImage?.source {

                Alert.showLoadingIndicatorAlert(onView: view)
                self.displayImage(withUrl: url)
            }
        }

    }
    
    func fetchLargeImageUrlFor(indexPath: IndexPath) {
        
        guard let id = self.tilesArray[indexPath.row].id else { print("Couldn't get id"); return }
        
        APIService.shared.fetchPhotoImage(withId: id, success: { (size) in
            
            if let largeImage = size.filter({ $0.label == "Large" }).first {
                
                self.largeImageArray.append(largeImage)
                
                if let largeImageUrl = largeImage.source {
                    self.displayImage(withUrl: largeImageUrl)
                }
            } else {
                Alert.showGeneralAlert(withMessage: "Couldn't get larger image for selected image. Please search again.")
            }
        }) { (error) in
            Alert.showGeneralAlert(withMessage: error.localizedDescription)
        }
    }
    
    func displayImage(withUrl url: String) {
        
        guard let url = URL(string: url) else { print("Couldn't get url"); return }
        
        UIImage.downloadImageFromUrl(url) { image in
            
            if image == nil {
                DispatchQueue.main.async() {
                    Alert.dismissLoadingIndicator()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        Alert.showGeneralAlert(withMessage: "Couldn't get image")
                    })
                }
            } else {
                DispatchQueue.main.async {
                    Alert.dismissLoadingIndicator()
                    self.view?.setLargeImage(withImage: image!)
                }
            }
        }
    }
    
//    func saveImage() {
//        for index in 0 ... imageGalleryViewModel.tilesArray.count - 1 {
//            let cell = imageGalleryCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PhotoCollectionViewCell
//            let imageData = cell?.imageView.image?.pngData() as NSData?
//            SizeManager.shared.saveSize(imageGalleryViewModel.tilesArray[index], andImage: imageData!)
//        }
//    }
}

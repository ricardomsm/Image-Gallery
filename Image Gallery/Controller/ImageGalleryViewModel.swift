//
//  ImageGalleryViewModel.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 27/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit
import CoreData
import Reachability

class ImageGalleryViewModel: ImageGalleryViewModelProtocol {
    
    //MARK: - Variables and constructor
    var view                 : ImageGalleryViewControllerProtocol?
    
    lazy var sizeArray        = [Size]()
    lazy var tilesArray       = [Size]()
    lazy var largeImageArray  = [Size]()
    lazy var imageCache       = NSCache<NSString, UIImage>()
    lazy var currentPage      = 1
    lazy var totalPages       = 0
    var isFetchingMore        = false
    var lastUserEnteredText   = ""
    let hasInternetConnection = Reachability()?.connection != .none
    
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
            
            DispatchQueue.main.async {
                self.view?.setImages()
            }
            
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
                        
                        DispatchQueue.main.async {
                            
                            self.view?.setImageOnCell(cell, withImage: image)
                            
                            if self.hasInternetConnection {
                                self.saveTileImage(withUrl: imageUrl, and: image)
                            }
                        }
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
        
        APIService.shared.fetchPhotoImage(withId: id, success: { size in
            
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
    
    func displayImage(withUrl imageUrl: String) {
        
        guard let url = URL(string: imageUrl) else { print("Couldn't get url"); return }
        
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
                    
                    if self.hasInternetConnection {
                        self.saveLargeImage(withUrl: imageUrl, andImage: image!)
                    }
                }
            }
        }
    }
    
    //MARK: Persistence methods
    func saveTileImage(withUrl imageUrl: String, and image: UIImage) {
        
        guard let size = tilesArray.first(where: { $0.source == imageUrl }) else { print("Couldn't find image with url"); return }
        guard let imageData = image.pngData() as NSData? else { print("Couldn't get image data"); return }
        
        SizeManager.shared.saveSize(size, andImage: imageData)
    }
    
    func saveLargeImage(withUrl url: String, andImage image: UIImage) {
        
        guard let size = largeImageArray.first(where: { $0.source == url }) else { print("Couldn't find image with url"); return }
        guard let imageData = image.pngData() as NSData? else { print("Couldn't get image data"); return }
        
        SizeManager.shared.saveSize(size, andImage: imageData)
    }
    
    func fetchStoredImages() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SizeManagedObject")
        
        do {
            
            guard let results = try SizeManager.shared.context?.fetch(fetchRequest) as? [NSManagedObject] else { return }
            guard let sizeMOArray = results as? [SizeManagedObject] else { return }
            
            sizeMOArray.forEach { sizeMO in
                
                if self.sizeArray.contains(where: { $0.id == sizeMO.id && ($0.label == "Large Square" || $0.label == "Large") }) {
                    return
                } else {
                    
                    let size = SizeMapper().size(fromManagedObject: sizeMO)
                    
                    self.sizeArray.append(size)
                }
            }
            
            self.tilesArray.append(contentsOf: self.sizeArray.filter({ $0.label == "Large Square" }))
            self.largeImageArray.append(contentsOf: self.sizeArray.filter({ $0.label == "Large" }))
            self.view?.setImages()
            
        } catch let error {
            print("Fetch error: \(error)")
        }
    }
    
}

//
//  ImageGalleryViewController.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 24/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit

struct ImageGalleryDimensions {
    fileprivate static let trailingAndLeadingMargin: CGFloat = 15
    fileprivate static let imageHeight: CGFloat = 150
}

class ImageGalleryViewController: UIViewController {

    //MARK: - Outlets and variables
    @IBOutlet var imageGalleryCollectionView : UICollectionView!
    @IBOutlet var imageSearchBar             : UISearchBar!
    private lazy var sizeArray               = [Size]()
    private lazy var tilesArray              = [Size]()
    private lazy var imageCache              = NSCache<NSString, UIImage>()
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupImageGalleryCollectionView()
    }
    
    //MARK: - UI setup
    private func setupSearchBar() {
        
        imageSearchBar.delegate = self
        imageSearchBar.placeholder = "Search for an image..."
    }
    
    private func setupImageGalleryCollectionView() {
        
        let imageWidth: CGFloat = (view.frame.width / 2) - 45
        
        let galleryLayout = UICollectionViewFlowLayout()
        galleryLayout.sectionInset = UIEdgeInsets(
            top: 0,
            left: ImageGalleryDimensions.trailingAndLeadingMargin,
            bottom: 0,
            right: ImageGalleryDimensions.trailingAndLeadingMargin
        )
        galleryLayout.itemSize = CGSize(width: imageWidth, height: ImageGalleryDimensions.imageHeight)
        
        imageGalleryCollectionView.collectionViewLayout = galleryLayout
        imageGalleryCollectionView.delegate = self
        imageGalleryCollectionView.dataSource = self
    }

}

//MARK: - Collection View delegate and datasource
extension ImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tilesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        if let imageURL = tilesArray[indexPath.row].source {
            // We use the url as to identify which cell should load which image
            cell.imageUrl = imageURL
            setupCell(withUrl: imageURL, image: imageCache.object(forKey: NSString(string: imageURL)), and: cell)
        }
    
        return cell
    }
    
    private func setupCell(withUrl url: String?, image: UIImage?, and cell: PhotoCollectionViewCell) {
        
        // We use the is hidden property as to hide the cell while there is no image
        cell.imageView.isHidden = true
        
        if image != nil {
            cell.imageView.image = image
            cell.imageView.isHidden = false
        } else {
            
            if let imageUrl = url {
                DispatchQueue.global(qos: .background).async {
                    
                    guard let url = URL(string: imageUrl) else { print("Error getting url"); return }
                    
                    UIImage.downloadImageFromUrl(url, returns: { image in
                        
                        self.imageCache.setObject(image, forKey: NSString(string: imageUrl))
                        
                        if cell.imageUrl == imageUrl {
                            
                            DispatchQueue.main.async {
                                cell.imageView.image = image
                                cell.imageView.isHidden = false
                            }
                        }
                    })
                }
            }
        }
    }
    
}

//MARK: - Search bar delegate methods
extension ImageGalleryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
        cleanGallery()
        
        APIService.shared.fetchImages(withText: searchBar.text, success: { sizeArray in
            
            self.sizeArray.append(contentsOf: sizeArray)
            self.tilesArray.append(contentsOf: sizeArray.filter({ $0.label == "Large Square" }))
            
            DispatchQueue.main.async {
                self.imageGalleryCollectionView.reloadData()
            }
            
        }) { error in
            print(error)
        }
    }
    
    private func cleanGallery() {
        sizeArray = []
        tilesArray = []
        imageCache.removeAllObjects()
        imageGalleryCollectionView.reloadData()
    }
}

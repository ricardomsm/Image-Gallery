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
    private var largeImageView               : UIImageView!
    private lazy var sizeArray               = [Size]()
    private lazy var tilesArray              = [Size]()
    private lazy var largeImageArray         = [Size]()
    private lazy var imageCache              = NSCache<NSString, UIImage>()
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupImageGalleryCollectionView()
        addDismissalTapGesture()
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
    
    //MARK: - Tap Gesture
    private func addDismissalTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissViews))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViews() {
        
        if imageSearchBar.isFirstResponder {
            imageSearchBar.resignFirstResponder()
        } else if largeImageView != nil {
            largeImageView.removeFromSuperview()
            largeImageView = nil
        }
    }

}

//MARK: - Collection View delegate and datasource
extension ImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tilesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        if let imageUrl = tilesArray[indexPath.row].source {
            // We use the url as to identify which cell should load which image
            cell.imageUrl = imageUrl
            setupCell(withUrl: imageUrl, image: imageCache.object(forKey: NSString(string: imageUrl)), and: cell)
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        clearLargeImage()
        
        /*
         Here we check if the user has scrolled down fast enough,
         that didn't allow time for the fetching all the large images,
         so we fetch them on the go
        */
        if indexPath.row >= largeImageArray.count || tilesArray[indexPath.row].id != largeImageArray[indexPath.row].id {
            
            Alert.showLoadingIndicatorAlert(onView: self)
            fetchAndDisplayLargeImage(withIndexPath: indexPath)
        } else {
            
            let largeImage = largeImageArray.filter({ $0.id == tilesArray[indexPath.row].id }).first
            
            if let url = largeImage?.source {
                
                Alert.showLoadingIndicatorAlert(onView: self)
                showLargeImage(withUrl: url)
            }

        }
    }
    
    //MARK: Collection view Helper Methods
    private func setupCell(withUrl url: String?, image: UIImage?, and cell: PhotoCollectionViewCell) {
        
        // We use the is hidden property as to hide the cell while there is no image
        cell.imageView.isHidden = true
        
        if image != nil {
            cell.imageView.image = image
            cell.imageView.isHidden = false
        } else {
            
            if let imageUrl = url {
                downloadAndSetImage(withUrl: imageUrl, on: cell)
            }
        }
    }
    
    private func downloadAndSetImage(withUrl imageUrl: String, on cell: PhotoCollectionViewCell) {
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
    
    private func clearLargeImage() {
        if largeImageView != nil {
            largeImageView.removeFromSuperview()
            largeImageView = nil
        }
    }
    
    private func showLargeImage(withUrl url: String) {
        
        DispatchQueue.main.async {
            self.largeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            self.largeImageView.contentMode = .scaleAspectFit
        }

        guard let url = URL(string: url) else { print("Couldn't get url"); return }
        
        UIImage.downloadImageFromUrl(url) { image in
            
            DispatchQueue.main.async {
                Alert.dismissLoadingIndicator()
                
                self.largeImageView.image = image
                self.largeImageView.image?.draw(at: self.largeImageView.center)
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.largeImageView.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.4)
                    self.view.addSubview(self.largeImageView)
                    self.view.bringSubviewToFront(self.largeImageView)
                })
            }
        }
    }
    
    private func fetchAndDisplayLargeImage(withIndexPath indexPath: IndexPath) {
        
        guard let id = tilesArray[indexPath.row].id else { print("Couldn't get id"); return }
        
        APIService.shared.fetchPhotoImage(withId: id, success: { (size) in
        
            if let largeImage = size.filter({ $0.label == "Large" }).first {
                
                self.largeImageArray.append(largeImage)
                
                if let largeImageUrl = largeImage.source {
                    self.showLargeImage(withUrl: largeImageUrl)
                }
            } else {
                Alert.showGeneralAlert(withMessage: "Couldn't get larger image for selected image. Please search again.")
            }
        }) { (error) in
            Alert.showGeneralAlert(withMessage: error.localizedDescription)
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
            self.largeImageArray.append(contentsOf: sizeArray.filter({ $0.label == "Large" }))
            
            DispatchQueue.main.async {
                self.imageGalleryCollectionView.reloadData()
            }
            
        }) { error in
            print(error)
        }
    }
    
    private func cleanGallery() {
        sizeArray.removeAll()
        tilesArray.removeAll()
        largeImageArray.removeAll()
        imageCache.removeAllObjects()
        imageGalleryCollectionView.reloadData()
    }
}

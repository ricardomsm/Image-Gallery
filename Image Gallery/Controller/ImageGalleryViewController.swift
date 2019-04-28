//
//  ImageGalleryViewController.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 24/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit

fileprivate struct ImageGalleryDimensions {
    fileprivate static let trailingAndLeadingMargin: CGFloat = 15
    fileprivate static let imageHeight: CGFloat = 150
}

class ImageGalleryViewController: UIViewController, ImageGalleryViewControllerProtocol {
    
    //MARK: - Outlets and variables
    @IBOutlet var imageGalleryCollectionView : UICollectionView!
    @IBOutlet var imageSearchBar             : UISearchBar!
    private var largeImageView               : UIImageView!
    private lazy var imageGalleryViewModel   = ImageGalleryViewModel(withView: self)

    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupImageGalleryCollectionView()
        addDismissalTapGesture()
        
        if !imageGalleryViewModel.hasInternetConnection {
            imageGalleryViewModel.fetchStoredImages()
        }
    }
    
    //MARK: - View Model Methods
    func setImages() {
        self.imageGalleryCollectionView.reloadData()
    }
    
    func setImageOnCell(_ cell: PhotoCollectionViewCell, withImage image: UIImage) {
        cell.imageView.image = image
        cell.imageView.isHidden = false
    }
    
    func setLargeImage(withImage image: UIImage) {
        
        self.largeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.largeImageView.contentMode = .scaleAspectFit
        
        self.largeImageView.image = image
        self.largeImageView.image?.draw(at: self.largeImageView.center)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.largeImageView.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.4)
            self.view.addSubview(self.largeImageView)
            self.view.bringSubviewToFront(self.largeImageView)
        })
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
        return imageGalleryViewModel.tilesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageUrl = ""
        
        if !imageGalleryViewModel.hasInternetConnection {
            
            guard let imageData = imageGalleryViewModel.tilesArray[indexPath.row].image else { print("error getting image data"); return cell }
            let image = UIImage(data: imageData as Data)
            cell.imageView.image = image
        } else {
            
            if let imageUrl = imageGalleryViewModel.tilesArray[indexPath.row].source {
                // We use the url as to identify which cell should load which image
                cell.imageUrl = imageUrl
                setupCell(withUrl: imageUrl, image: imageGalleryViewModel.imageCache.object(forKey: NSString(string: imageUrl)), and: cell)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        clearLargeImage()
        
        if !imageGalleryViewModel.hasInternetConnection {
            
            let selectedImageId = imageGalleryViewModel.tilesArray[indexPath.row].id
            guard let imageData = imageGalleryViewModel.largeImageArray.filter({ $0.id == selectedImageId }).first?.image else { print("Error getting image data")
                Alert.showGeneralAlert(withMessage: "Please enable internet connection to get larger image")
                return
            }
            
            guard let image = UIImage(data: imageData as Data) else {
                print("error getting image from data")
                Alert.showGeneralAlert(withMessage: "Please enable internet connection to get larger image")
                return
            }
            
            setLargeImage(withImage: image)
        } else {
            imageGalleryViewModel.showLargeImage(forIndexPath: indexPath)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !imageGalleryViewModel.hasInternetConnection {
            Alert.showGeneralAlert(withMessage: "Please enable internet connection to search for images")
            return
        }
        
        /*
         Here we check if the user is scrolling downwards, and when he reach the bottom,
         we begin a new fetch for images.
        */
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offSetY > contentHeight - scrollView.frame.height {
            
            if !imageGalleryViewModel.isFetchingMore {
                Alert.showLoadingIndicatorAlert(onView: self)
                imageGalleryViewModel.beginBatchFetch()
            }
        }
    }

    //MARK: Collection view Helper Methods
    private func setupCell(withUrl url: String?, image: UIImage?, and cell: PhotoCollectionViewCell) {
        
        // We use the isHidden property as to hide the cell while there is no image
        cell.imageView.isHidden = true
        
        if image != nil {
            cell.imageView.image = image
            cell.imageView.isHidden = false
        } else {
            
            if let imageUrl = url {
                imageGalleryViewModel.getImage(withUrl: imageUrl, for: cell)
            }
        }
    }
    
    private func clearLargeImage() {
        if largeImageView != nil {
            largeImageView.removeFromSuperview()
            largeImageView = nil
        }
    }
}

//MARK: - Search bar delegate methods
extension ImageGalleryViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        SizeManager.shared.deleteAll("SizeManagedObject")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
        cleanGallery()
        
        if let text = searchBar.text {
            imageGalleryViewModel.fetchImages(withText: text)
        } else {
            Alert.showGeneralAlert(withMessage: "Please enter some text.")
        }
    }
    
    private func cleanGallery() {
        imageGalleryViewModel.sizeArray.removeAll()
        imageGalleryViewModel.tilesArray.removeAll()
        imageGalleryViewModel.largeImageArray.removeAll()
        imageGalleryViewModel.imageCache.removeAllObjects()
        imageGalleryCollectionView.reloadData()
    }
}

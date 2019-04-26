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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        
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
    
        if let url = largeImageArray[indexPath.row].source {
            
            largeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 40))
            largeImageView.contentMode = .scaleAspectFit
            
            Alert.showLoadingIndicatorAlert(onView: self)
            
            showLargeImage(withUrl: url)
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

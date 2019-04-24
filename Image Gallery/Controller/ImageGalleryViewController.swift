//
//  ImageGalleryViewController.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 24/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController {

    //MARK: - Outlets and variables
    @IBOutlet var imageGalleryCollectionView: UICollectionView!
    @IBOutlet var imageSearchBar: UISearchBar!
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIService.shared.fetchImages(withText: "kitten")
        setupSearchBar()
        setupImageGalleryCollectionView()
    }
    
    //MARK: - UI setup
    private func setupSearchBar() {
        
        imageSearchBar.delegate = self
        imageSearchBar.placeholder = "Search for an image..."
    }
    
    private func setupImageGalleryCollectionView() {
        
        let galleryLayout = UICollectionViewFlowLayout()
        galleryLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        galleryLayout.itemSize = CGSize(width: (view.frame.width / 2) - 45, height: 150)
        
        imageGalleryCollectionView.collectionViewLayout = galleryLayout
        imageGalleryCollectionView.delegate = self
        imageGalleryCollectionView.dataSource = self
    }

}

//MARK: - Collection View delegate and datasource
extension ImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        return cell
    }
    
    
    
}

//MARK: - Search bar delegate methods
extension ImageGalleryViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

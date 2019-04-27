//
//  APIService.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 24/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import UIKit


class APIService {
    
    static let shared = APIService()

    private var baseUrlComponents          = URLComponents(string: "https://api.flickr.com/services/rest/")
    private lazy var apiKeyQueryItem       = URLQueryItem(name: "api_key", value: "f9cc014fa76b098f9e82f1c288379ea1")
    private lazy var jsonFormatQueryItem   = URLQueryItem(name: "format", value: "json")
    private lazy var jsonCallbackQueryItem = URLQueryItem(name: "nojsoncallback", value: "1")
    
    func fetchImages(withText text: String?, success: @escaping (_ sizeArray: [Size]) -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let endpointQueryItem     = URLQueryItem(name: "method", value: "flickr.photos.search")
        let tagsQueryItem         = URLQueryItem(name: "tags", value: text)
        baseUrlComponents?.queryItems = [
            endpointQueryItem,
            apiKeyQueryItem,
            tagsQueryItem,
            jsonFormatQueryItem,
            jsonCallbackQueryItem
        ]
        
        guard let url = baseUrlComponents?.url else { print("Error getting url"); return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            
            let response = response as? HTTPURLResponse
            print("Response status code: \(String(describing: response?.statusCode))")
            print("Response: \(String(describing: response))")
            
            if let error = error {
                print(error)
                Alert.showGeneralAlert(withMessage: error.localizedDescription)
                return
            }
            
            guard let data = data else { print("Error getting data"); return }

            let decoder = JSONDecoder()
            
            do {
                
                let searchPhotosResponse = try decoder.decode(SearchPhotosResponse.self, from: data)
                print(searchPhotosResponse)
                
                searchPhotosResponse.photos?.photo?.forEach({ photo in
                    
                    guard let photoId = photo.id else { print("Couldn't get photo id"); return }
                    
                    self?.fetchPhotoImage(withId: photoId, success: { sizeArray in
                        success(sizeArray)
                    }, failure: { error in
                        print(error)
                        failure(error)
                    })
                })
                
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
    func fetchPhotoImage(withId id: String, success: @escaping (_ sizes: [Size]) -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let endpointQueryItem = URLQueryItem(name: "method", value: "flickr.photos.getSizes")
        let photoIdQueryItem = URLQueryItem(name: "photo_id", value: id)
        baseUrlComponents?.queryItems = [
            endpointQueryItem,
            apiKeyQueryItem,
            photoIdQueryItem,
            jsonFormatQueryItem,
            jsonCallbackQueryItem
        ]
        
        guard let url = baseUrlComponents?.url else { print("Couldn't get url from url components"); return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let response = response as? HTTPURLResponse
            print("Response status code: \(String(describing: response?.statusCode))")
            print("Response: \(String(describing: response))")
            
            if let error = error {
                print(error)
                Alert.showGeneralAlert(withMessage: error.localizedDescription)
                failure(error)
            }
            
            guard let data = data else { print("Error getting data"); return }

            do {
                
                let searchSizeJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : Any]
                print(searchSizeJSON)
                
                let searchSizeResponse = SearchSizeResponse(withDictionary: searchSizeJSON)
                
                guard var size = searchSizeResponse.sizes?.size?.filter({ $0.label == "Large Square" || $0.label == "Large" }) else { print("Error getting size array"); return }
                
                /*
                 Here we go through the array as to assign a photo an id,
                 as to prevent loading an incorrect photo while clicking another one,
                 on the view controller
                */
                for index in 0...size.count - 1 {
                    size[index].assignId(withId: id)
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                success(size)
                
            } catch let error {
                print(error)
                failure(error)
            }
            
        }.resume()
    }
    
}

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
    let urlSession    = URLSession.shared
    
    private let APIKey                     = "f9cc014fa76b098f9e82f1c288379ea1"
    private let baseUrl                    = "https://api.flickr.com/services/rest/"
    private lazy var apiKeyQueryItem       = URLQueryItem(name: "api_key", value: APIKey)
    private lazy var jsonFormatQueryItem   = URLQueryItem(name: "format", value: "json")
    private lazy var jsonCallbackQueryItem = URLQueryItem(name: "nojsoncallback", value: "1")
    
    func fetchImages(withText text: String?) {
        
        guard var urlComponents = URLComponents(string: baseUrl) else { print("Error generating url components from string"); return }
        
        let endpointQueryItem     = URLQueryItem(name: "method", value: "flickr.photos.search")
        let tagsQueryItem         = URLQueryItem(name: "tags", value: text)
        urlComponents.queryItems = [
            endpointQueryItem,
            apiKeyQueryItem,
            tagsQueryItem,
            jsonFormatQueryItem,
            jsonCallbackQueryItem
        ]
        
        guard let url = urlComponents.url else { print("Error getting url"); return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        urlSession.dataTask(with: url) { [weak self] (data, response, error) in
            
            let response = response as? HTTPURLResponse
            print("Response status code: \(String(describing: response?.statusCode))")
            print("Response: \(String(describing: response))")
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { print("Error getting data"); return }

            let decoder = JSONDecoder()
            
            do {
                let searchPhotosResponse = try decoder.decode(SearchPhotosResponse.self, from: data)
                
                searchPhotosResponse.photos?.photo?.forEach({ self?.fetchPhotoImage(withId: $0.id!) })
                
            } catch let error {
                print(error)
            }
            
        }.resume()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func fetchPhotoImage(withId id: String) {
        
        guard var urlComponents = URLComponents(string: baseUrl) else { print("Couldn't get url"); return }
        
        let endpointQueryItem = URLQueryItem(name: "method", value: "flickr.photos.getSizes")
        let photoIdQueryItem = URLQueryItem(name: "photo_id", value: id)
        urlComponents.queryItems = [
            endpointQueryItem,
            apiKeyQueryItem,
            photoIdQueryItem,
            jsonFormatQueryItem,
            jsonCallbackQueryItem
        ]
        
        guard let url = urlComponents.url else { print("Couldn't get url from url components"); return }
        
        urlSession.dataTask(with: url) { [weak self]  (data, response, error) in
            
            let response = response as? HTTPURLResponse
            print("Response status code: \(String(describing: response?.statusCode))")
            print("Response: \(String(describing: response))")
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { print("Error getting data"); return }

            do {
                let searchSizeJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String : Any]
                
                let searchSizeResponse = SearchSizeResponse(withDictionary: searchSizeJSON)
                let size = searchSizeResponse.sizes?.size?.filter({ $0.label == "Large Square" || $0.label == "Large" })
                
                // Call protocol method on view to reload collecttion view data
                
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
}

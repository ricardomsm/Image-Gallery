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
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            
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
    
    func fetchPhotoImage(withId: String) {
        //TODO: Finish implementing fetching photo images
        guard var urlComponents = URLComponents(string: baseUrl) else { print("Couldn't get url"); return }
    }
    
}

//
//  APIService.swift
//  Image Gallery
//
//  Created by Ricardo Magalhães on 24/04/2019.
//  Copyright © 2019 ricardomm. All rights reserved.
//

import Foundation

class APIService {
    
    static let shared = APIService()
    
    private let APIKey  = "f9cc014fa76b098f9e82f1c288379ea1"
    private let baseUrl = "https://api.flickr.com/services/rest/"
    
    func fetchImages(withText text: String?) {
        
        guard var urlComponents = URLComponents(string: baseUrl) else { print("Error generating url components from string"); return }
        
        let endpointQueryItem    = URLQueryItem(name: "method", value: "flickr.photos.search")
        let apiKeyQueryItem      = URLQueryItem(name: "api_key", value: APIKey)
        let tagsQueryItem        = URLQueryItem(name: "tags", value: text)
        let jsonFormatQueryItem  = URLQueryItem(name: "format", value: "json")
        urlComponents.queryItems = [endpointQueryItem, apiKeyQueryItem, tagsQueryItem, jsonFormatQueryItem]
        
        guard let url = urlComponents.url else { print("Error getting url"); return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { print("Error getting data"); return }
            
            let decoder = JSONDecoder()
            
            do {
                let photos = try decoder.decode(Photos.self, from: data)
                print(photos)
                
                self?.fetchPhotoImage()
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
    func fetchPhotoImage() {
        //TODO: Implement fetching image with photo id
    }
    
}

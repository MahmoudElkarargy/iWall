//
//  Client.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import Foundation

class Client{
    //https://api.unsplash.com/
    // Access key: wnBp7ShjZwuTO2RmIZ6mBlFlO5sqW_xz5tUqFKgi6Zo
    //https://api.unsplash.com/search/photos?query=iphone-wallpaper&client_id=wnBp7ShjZwuTO2RmIZ6mBlFlO5sqW_xz5tUqFKgi6Zo
    //Edit per page.
    
    //d3fdcd22da4aee1a7e16b12e5a4cc4190bb20db15d7fdc20
    
    // MARK: Struct to hold the Authentication keys.
    struct Auth {
        static var accessKey = "wnBp7ShjZwuTO2RmIZ6mBlFlO5sqW_xz5tUqFKgi6Zo"
        static var secretKey = "eiESfsgDjIH6CzJx9O-3yr2Wd_RLW0Wwovm5g9HbPPA"
        
    }
    
    // MARK: EndPoints.
    enum EndPoints{
        static let base = "https://api.unsplash.com/"
    
        case searchImages(target: String)
//        case angz
        var stringValue: String{
            switch self {
            case .searchImages(let target):
                return EndPoints.base + "search/photos?query=\(target)"
                    + "&per_page=1&client_id=\(Auth.accessKey)"
//            case .angz:
//                return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=446cd218ea26fd83ea868f73085551f9&media=photos&lat=29.408956240328962&lon=31.73631041977589&radius=15&per_page=18&page=1&format=json&nojsoncallback=1"
            }
        }
        var url: URL {
            print("URL: \(stringValue)")
            return URL(string: stringValue)!
        }
    }
    
    // MARK: Get Search Data.
//    class func getPhotosSearchResult(lat:Double,lon:Double, page: Int ,completionHandler: @escaping (ImagesSearchResponse?, Error?) -> Void){
    class func getPhotosSearchResult(target: String ,completionHandler: @escaping (Bool?, Error?) -> Void){
            
        let q = DispatchQueue.global(qos: .userInteractive)
        q.async {
            let task = URLSession.shared.dataTask(with: EndPoints.searchImages(target: target).url) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        completionHandler(false, error)
                    }
                    return
                }
                do {
                    print(String(data: data, encoding: .utf8)!)
                    let decoder = JSONDecoder()
                    let responseObject = try decoder.decode(ImagesSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        print("kolo tamam")
                            completionHandler(true, nil)
                        }
                    } catch {
                       DispatchQueue.main.async {
                        print("no")
                            completionHandler(nil, error)
                        }
                    }
                }
                task.resume()
            }
        }
}

//
//  Client.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import Foundation

class Client{


    // MARK: Struct to hold the Authentication keys.
    struct Auth {
        static var key = "16453561-407af218bb4dc4ba3f3219e21"
    }

    // MARK: EndPoints.
    enum EndPoints{
        static let base = "https://pixabay.com/api/?key=" + Auth.key

        case searchImages
        var stringValue: String{
            switch self {
            case .searchImages:
                return EndPoints.base 
//             "https://pixabay.com/api/?key=16453561-407af218bb4dc4ba3f3219e21&q=yellow+flowers&image_type=photo&pretty=true"
            }
        }
        var url: URL {
            print("URL: \(stringValue)")
            return URL(string: stringValue)!
        }
    }

//    // MARK: Get Search Data.
//    class func getPhotosSearchResult(lat:Double,lon:Double, page: Int ,completionHandler: @escaping (ImagesSearchResponse?, Error?) -> Void){
    class func getPhotosSearchResult(target: String ,completionHandler: @escaping (Bool?, Error?) -> Void){

        let q = DispatchQueue.global(qos: .userInteractive)
        q.async {
            let task = URLSession.shared.dataTask(with: EndPoints.searchImages.url) { data, response, error in
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

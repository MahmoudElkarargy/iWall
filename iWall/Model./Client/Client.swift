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

        case searchImages(tag: String, minWidth: Int, minHeight: Int, page: Int)
        var stringValue: String{
            switch self {
            case .searchImages(let tag, let minWidth, let minHeight, let page):
                return EndPoints.base + "&q=iPhone+\(tag)" + "&min_width=\(minWidth)&min_height=\(minHeight)"
                        + "&per_page=10&page=\(page)&image_type=photo"
            }
        }
        var url: URL {
//            print("URL: \(stringValue)")
            return URL(string: stringValue)!
        }
    }

    // MARK: Get Search Data.
    class func getPhotosSearchResult(tag: String, minWidth:Int, minHeight:Int ,page:Int,completionHandler: @escaping (ImagesSearchResponse?, Error?) -> Void){
        
        let q = DispatchQueue.global(qos: .userInteractive)
        q.async {
            let task = URLSession.shared.dataTask(with: EndPoints.searchImages(tag: tag, minWidth: minWidth, minHeight: minHeight, page: page).url) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                    return
                }
                do {
                    print(String(data: data, encoding: .utf8)!)
                    let decoder = JSONDecoder()
                    let responseObject = try decoder.decode(ImagesSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        print("Response is succeful")
                            completionHandler(responseObject, nil)
                        }
                    } catch {
                       DispatchQueue.main.async {
                            completionHandler(nil, error)
                        }
                    }
                }
                task.resume()
            }
    }
    
}

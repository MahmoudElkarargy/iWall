//
//  ImageSelectedViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/9/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit

class ImageSelectedViewController: UIViewController {
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var likedImage: UIButton!
    @IBOutlet weak var imageTag: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    var imageURL: String!
    var labelText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageTag.text = labelText
        downloadFullQualityImage()
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        print("fe howar?")
        self.dismiss(animated: true) 
    }
    func downloadFullQualityImage(){
        downloadImage(url: (imageURL)!) { (image) -> Void in
            // display it
            self.imageview.image = image
        }
    }
    
    // this method downloads a huge image on a global queue
    // once finished, the completion closure runs with the image
    func downloadImage(url:String, completionHandler handler: @escaping (UIImage?) -> Void){
        DispatchQueue.global(qos: .userInitiated).async {
            // use url to get the data for the image
            print("testing url")
            if let url = URL(string: url), let imgData = try? Data(contentsOf: url) {
                print("url is good")
                // turn data into an image
                let image = UIImage(data: imgData)
                print("turned into image")
                // always run completion handler in the main queue, just in case!
                DispatchQueue.main.async {
                    print("return itt")
                    handler(image)
                }
            }
        }
    }
}

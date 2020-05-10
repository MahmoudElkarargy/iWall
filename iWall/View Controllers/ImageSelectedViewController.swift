//
//  ImageSelectedViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/9/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit

class ImageSelectedViewController: UIViewController {
    //MARK: Outlets and variables.
    @IBOutlet weak var likedImage: UIButton!
    @IBOutlet weak var imageTag: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shareButton: UIButton!
    var imageURL: String!
    var labelText: String!
    
    //MARK: Override functions.
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the image text.
        imageTag.text = labelText
        //Set the image to placeholder image.
        imageview.image = UIImage(named: "placeholderImage")!
        //start animating.
        activityIndicator.startAnimating()
        //hide Share button untill loding is complete
        shareButton.isHidden = true
        //Download the Full high Quality of the image, N.B: the images in the search are in low quality to be able to view them fast as possiable.
        downloadFullQualityImage()
    }
    //MARK: IBAction func.
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func downloadImageTapped(_ sender: Any) {
        let imageShare = [ imageview.image ]
        let controller = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
        present(controller,animated: true, completion: nil)
    }
    
    //MARK: Helper functions.
    func downloadFullQualityImage(){
        downloadImage(url: (imageURL)!) { (image) -> Void in
            // display it
            self.imageview.image = image
            //Stop animating!
            self.activityIndicator.stopAnimating()
            //unhide Share button.
            self.shareButton.isHidden = false
        }
    }
    // this method downloads a huge image on a global queue
    // once finished, the completion closure runs with the image
    func downloadImage(url:String, completionHandler handler: @escaping (UIImage?) -> Void){
        DispatchQueue.global(qos: .userInitiated).async {
            // use url to get the data for the image
            if let url = URL(string: url), let imgData = try? Data(contentsOf: url) {
                // turn data into an image
                let image = UIImage(data: imgData)
                // always run completion handler in the main queue, just in case!
                DispatchQueue.main.async {
                    handler(image)
                }
            }
        }
    }
}

//
//  ImageSelectedViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/9/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import Firebase

class ImageSelectedViewController: UIViewController {
    //MARK: Outlets and variables.
    @IBOutlet weak var likedImage: UIButton!
    @IBOutlet weak var imageTag: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shareButton: UIButton!
    var imageURL: String!
    var imageID: Int!
    var labelText: String!
    var isfirstCliked = true
    var storageRef: StorageReference!
    var ref: DatabaseReference?
    var numberOfSavedImages: Int = 0
    var storagePath: String = ""
    //MARK: Override functions.
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up the storage.
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        storageRef = storage.reference()
        //instance of FIRDatabaseReference.
        ref = Database.database().reference()
        //Set the image text.
        imageTag.text = labelText
        //Set the image to placeholder image.
        imageview.image = UIImage(named: "placeholderImage")!
        //start animating.
        activityIndicator.startAnimating()
        //hide Share button and like button untill loding is complete
        shareButton.isHidden = true
        likedImage.isHidden = true
        //Download the Full high Quality of the image, N.B: the images in the search are in low quality to be able to view them fast as possiable.
        downloadFullQualityImage()
        //Set the like button
        setLikeButton()
    }
    //MARK: IBAction func.
    @IBAction func backButtonTapped(_ sender: Any) {
        HomeViewController.calledFromImageSelectedView()
        self.dismiss(animated: true)
    }
    @IBAction func downloadImageTapped(_ sender: Any) {
        let imageShare = [ imageview.image ]
        let controller = UIActivityViewController(activityItems: imageShare, applicationActivities: nil)
        present(controller,animated: true, completion: nil)
    }
    @IBAction func likeImage(_ sender: Any) {
//        Changing the like image.
        if isfirstCliked{
            likedImage.setImage(UIImage(named: "liked"), for: .normal)
            isfirstCliked = !isfirstCliked
            //transform the photo into data
            let photoData = imageview.image!.jpegData(compressionQuality: 0.8)
            //Call the function to upload photo in the storage.
            uploadPhoto(photoData: photoData!)
        }
        else{
            likedImage.setImage(UIImage(named: "love"), for: .normal)
            isfirstCliked = !isfirstCliked
            //Search for image.
            let index = UserData.photosID.firstIndex(of: imageID)!
            //Removing the liked image URL and it's path from the storage.
            deleteImage(index)
        }
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
            self.likedImage.isHidden = false
        }
    }
    func deleteImage(_ index: Int){
        //Remove it from Storage
        // Create a reference to the file to delete
        var path = UserData.photosStorageURL[index]
        //27 to remove "gs://iwall-5521.appspot.com"
        let desertRef = storageRef.child(path[27...])
        // Delete the file
        desertRef.delete { error in
          if let error = error {
            // Uh-oh, an error occurred!
            print("Error: \(error)")
          } else {
            // File deleted successfully, delete it from array.
            UserData.photosID.remove(at: index)
            UserData.photosStorageURL.remove(at: index)
            //Remove all photos from data base and then add them agian to be sure of their indexs.
            for image in 0...UserData.photosStorageURL.count{
                //Remove it from database.
                Database.database().reference().child("users").child(UserData.uid).child("photo\(image)").removeValue()
                Database.database().reference().child("users").child(UserData.uid).child("photoURL\(image)").removeValue()
            }
            //Add them agian manually.
            for image in 0...UserData.photosStorageURL.count-1{
                self.ref!.child("users/\(UserData.uid)/photo\(image)").setValue(UserData.photosStorageURL[image])
                self.ref!.child("users/\(UserData.uid)/photoURL\(image)").setValue(UserData.photosID[image])
            }
          }
        }
    }
    func setLikeButton(){
        if UserData.photosID.contains(imageID){
            likedImage.setImage(UIImage(named: "liked"), for: .normal)
            isfirstCliked = false
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
    func uploadPhoto(photoData: Data){
        //Build a path using the user's ID and a timeStamp.
        let imagePath = "UserLikedPhotos/" + UserData.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        //Set content type to "image/jpeg" in the firebase storage meta data.
        let metedata = StorageMetadata()
        metedata.contentType = "image/jpeg"
        //create the child node at imagePath with photoData and metaData.
        storageRef!.child(imagePath).putData(photoData, metadata: metedata) { (metadata, error) in
            guard let error = error else {
                //an error occurred!
                return
            }
        }
        storagePath = self.storageRef!.child((metedata.path)!).description
        //Add it to the dataBase.
        numberOfSavedImages = UserData.photosID.count
        self.ref!.child("users/\(UserData.uid)/photo\(numberOfSavedImages)").setValue(storagePath)
        self.ref!.child("users/\(UserData.uid)/photoURL\(numberOfSavedImages)").setValue(imageID)
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

//
//  HomeViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import UnsplashPhotoPicker

class HomeViewController: UIViewController{
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElments()
    }
    func setUpElments(){
        Utilities.styleTextField(typeTextField, placeHolderString: "iPhone")
        Utilities.styleTextField(tagTextField, placeHolderString: "Add tag.")
        
        
//        Client.getPhotosSearchResult(target: "iphone") { (bool, error) in
//            print("edaa")
//        }
        UnsplashPhotoPickerConfiguration(accessKey: Client.Auth.accessKey, secretKey: Client.Auth.secretKey)
        
    }
}

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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        print("fe howar?")
        self.dismiss(animated: true) 
    }
    
}

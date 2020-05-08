//
//  FirstViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    //MARK: Outlets.
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElments()
    }

    func setUpElments(){
        //Styling the elments
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signUpButton)
    }
}


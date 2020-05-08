//
//  LoginViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    //MARK: Outlets.
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElments()
    }
    
    func setUpElments(){
        //Hide the error label.
        errorLabel.alpha = 0
        //Styling the elments
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
    }
    
}

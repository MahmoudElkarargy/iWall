//
//  LoginViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import FirebaseAuth

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
    //Signing the user.
    @IBAction func loginTapped(_ sender: Any) {
        //Create cleaned virsions of data
        let email = self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil{
                //Couldn't sign in.
                self.ShowError(error!.localizedDescription)
            }
            else{
                //Transition to the home screen.
                self.TransitionToHome()
            }
        }
    }
    func ShowError(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func TransitionToHome(){
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.StoryBoard.homeViewController)
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}

//
//  SignUpViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {

    //MARK: Outlets.
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElments()
    }
   
    func setUpElments(){
        //Hide the error label.
        errorLabel.alpha = 0
        //Styling the elments
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    //Check the fields and validate the data is correct or not.
    func ValidateFields() -> String? {
        //Check all the fields are filled in.
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields."
        }
        let isValidEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isEmailValid(isValidEmail) == false{
            //Email isn't valid.
            return "Please enter a valid email address."
        }
        //Check if the password is secure.
        let isValidPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(isValidPassword) == false{
            //Password isn't secure enough.
            return "Please make sure your password is at least 8 charcters, contains a special charcter and a number."
        }
        //Indicating that nothing went wrong.
        return nil
    }
    @IBAction func signUpTapped(_ sender: Any) {
        //Validate the fields
        let error = ValidateFields()
        if error != nil{
            //Show error msg
            ShowError(error!)
        }
        else {
            //Create cleaned virsions of data
            let firstName = self.firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = self.lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = self.passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                //check for erros.
                if error != nil{
                    //There was an error creating User.
                    self.ShowError(error!.localizedDescription)
                }
                else{
                    //User was created succesfully, now store the first and last name.
                    let db = Firestore.firestore()

                    db.collection("users").addDocument(data: [
                        "firstName": firstName,
                        "lastName": lastName,
                        "uid": result!.user.uid
                    ]) { err in
                        if let err = err {
                            self.ShowError("Error adding user: \(err)")
                        } else {
                            print("Document added with ID:")
                        }
                    }
                    //Transition to the home screen.
                    self.TransitionToHome()
                }
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

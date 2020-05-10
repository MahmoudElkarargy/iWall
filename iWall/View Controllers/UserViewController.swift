//
//  UserViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/10/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class UserViewController: UIViewController, UITextFieldDelegate {

    //MARK: Outlets and variables.
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likesLabel: UILabel!
    var ref: DatabaseReference?
    
    //MARK: Override funcs.
    override func viewDidLoad() {
        //instance of FIRDatabaseReference.
        ref = Database.database().reference()
        super.viewDidLoad()
        setUpElments()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if return is pressed resign first responder to hide keyboard
        textField.resignFirstResponder()
        updateUserName(textField)
        return true
    }
    //MARK: Setup funcs.
    func setUpElments(){
        //Hide the error label.
        errorLabel.alpha = 0
        //Styling the elments
        Utilities.styleTextField(nameTextField, placeHolderString: "")
        Utilities.styleTextField(lastNameTextField, placeHolderString: "")
        nameTextField.delegate = self
        lastNameTextField.delegate = self
        //Set texts.
        nameTextField.text = UserData.firstName
        lastNameTextField.text = UserData.lastName
    }
    
    //MARK: IBActions funcs.
    @IBAction func logoutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            //remove the saved email and password!
            UserDefaults.standard.set("", forKey: "savedEmail")
            UserDefaults.standard.set("", forKey: "savedPassword")
            //delete the saved UserData.
            UserData.firstName = ""
            UserData.lastName = ""
            UserData.phoneDevice = ""
            UserData.uid = ""
            //return To First View.
            let firstViewController = self.storyboard?.instantiateViewController(identifier: Constants.StoryBoard.firstViewController)
            self.view.window?.rootViewController = firstViewController
            self.view.window?.makeKeyAndVisible()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
          ShowMessage("Error signing out",true)
        }
    }
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Helper funcs.
    func updateUserName (_ textField: UITextField){
        if textField == nameTextField{
            if nameTextField.text != UserData.firstName{
                //User have updated his first name.
                self.ref!.child("users/\(UserData.uid)/firstName").setValue(nameTextField.text)
                self.ShowMessage("First name updated.", false)
            }
        }
        if textField == lastNameTextField{
            if lastNameTextField.text != UserData.lastName{
                //User have updated his first name.
                self.ref!.child("users/\(UserData.uid)/lastName").setValue(lastNameTextField.text)
                self.ShowMessage("Last name updated.", false)
            }
        }
    }
    func ShowMessage(_ message: String, _ error: Bool){
        //To be able to view errors and updates in the same time
        if error {
            errorLabel.textColor = UIColor.red
        } else {
            errorLabel.textColor = UIColor.green
        }
        errorLabel.text = message
        errorLabel.alpha = 1
    }
}

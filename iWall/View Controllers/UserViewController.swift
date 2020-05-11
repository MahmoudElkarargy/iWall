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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var ref: DatabaseReference?
    
    //MARK: Override funcs.
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        //Bring the activityIndicator in the front!
        self.view.bringSubviewToFront(activityIndicator)
        //Start animating.
        if UserData.photosStorageURL.count > 0 {
            self.activityIndicator.startAnimating()
        }
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
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateUserName(textField)
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
            UserData.photosID.removeAll()
            UserData.photosStorageURL.removeAll()
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

//MARK: CollectionView extension.
extension UserViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        likesLabel.text = "\(UserData.photosStorageURL.count) liked image."
        return UserData.photosStorageURL.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LikesCollectionViewCell
        //Setting up the cell.
        cell.imageView.image = UIImage(named: "placeholderImage")!
        
        //Downloading and display image from storage.
        Storage.storage().reference(forURL: UserData.photosStorageURL[indexPath.row]).getData(maxSize: INT64_MAX) { (data, error) in
            guard error == nil else{
                print("Error downloading! \(error)")
                return
            }
            //Check if the cell still on screen, if so, update it!
            if cell == collectionView.cellForItem(at: indexPath){
                DispatchQueue.main.async {
                    //Display image.
                    cell.imageView.image = UIImage(data: data!)
                    cell.setNeedsLayout()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        return cell
    }
}

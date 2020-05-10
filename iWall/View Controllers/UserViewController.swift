//
//  UserViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/10/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likesLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func logoutTapped(_ sender: Any) {
        print("Logging out")
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            print("logouded out")
            //remove the saved email and password!
            UserDefaults.standard.set("", forKey: "savedEmail")
            UserDefaults.standard.set("", forKey: "savedPassword")
            UserDefaults.standard.set("", forKey: "savedDevice")
            //return To First View.
            let firstViewController = self.storyboard?.instantiateViewController(identifier: Constants.StoryBoard.firstViewController)
            self.view.window?.rootViewController = firstViewController
            self.view.window?.makeKeyAndVisible()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
          print ("ERROR:Error signing out: %@", signOutError)
        }
    }
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

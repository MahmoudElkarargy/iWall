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
import ARKit

class SignUpViewController: UIViewController, UITextFieldDelegate{

    //MARK: Outlets and variables.
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activivtyIndicator: UIActivityIndicatorView!
    var videoPlayerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?

    //MARK: Override funcs.
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElments()
    }
    override func viewWillAppear(_ animated: Bool) {
        //Set the video in the background.
       setUpVideo()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if return is pressed resign first responder to hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Setup funcs.
    func setUpElments(){
        //Hide the error label.
        errorLabel.alpha = 0
        //Styling the elments
        Utilities.styleTextField(firstNameTextField, placeHolderString: "First Name.")
        Utilities.styleTextField(lastNameTextField, placeHolderString: "Last Name.")
        Utilities.styleTextField(emailTextField, placeHolderString: "Email.")
        Utilities.styleTextField(passwordTextField, placeHolderString: "Password.")
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(backButton)
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    func setUpVideo(){
        //Get the path to the resource movie.
        let bandlePath = Bundle.main.path(forResource: "signup", ofType: "mp4")
        guard bandlePath != nil else { return }
        //Create the url from it.
        let url = URL(fileURLWithPath: bandlePath!)
        //Create the video player item.
        let item = AVPlayerItem(url: url)
        //Create the player.
        player = AVQueuePlayer()
        //Create the layer.
        videoPlayerLayer = AVPlayerLayer(player: player!)
        let duration = Int64( ( (Float64(CMTimeGetSeconds(AVAsset(url: url).duration)) *  10.0) - 1) / 10.0 )
        //create a loop.
        playerLooper = AVPlayerLooper(player: player!, templateItem: item, timeRange: CMTimeRange(start: CMTime.zero, end: CMTimeMake(value: duration, timescale: 1)) )
        //Adjust the size and frame.
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*0.3, y: 0, width: self.view.frame.size.width*1.5, height: self.view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        //Add it to the view and play it.
        player?.playImmediately(atRate: 0.7)
    }
    //Show and hide elments depends on login case.
    func setLoggingIn (_ loggingIn: Bool){
        loggingIn ? activivtyIndicator.startAnimating() : activivtyIndicator.stopAnimating()
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        firstNameTextField.isEnabled = !loggingIn
        lastNameTextField.isEnabled = !loggingIn
        signUpButton.isEnabled = !loggingIn
        errorLabel.alpha = 0
    }
    
    //MARK: IBActions Functions.
    @IBAction func signUpTapped(_ sender: Any) {
        setLoggingIn(true)
        //close the keyboard.
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
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
                    guard let uid = result?.user.uid else {
                        print("Error: User isn't added")
                        return
                    }
                                        
                    //Add the user data to the database.
                    let ref = Database.database().reference()
                    let userReference = ref.child("users").child(uid)
                    let values = ["firstName": firstName, "lastName": lastName, "deviceType": ""]
                    //Save the userData.
                    UserData.firstName = firstName
                    UserData.lastName = lastName
                    UserData.phoneDevice = ""
                    UserData.uid = uid
                    userReference.updateChildValues(values) { (error, ref) in
                        if error != nil{
                            print("Error \(error)")
                        }                       
                    }
                    //Save the email and password!
                    UserDefaults.standard.set(email, forKey: "savedEmail")
                    UserDefaults.standard.set(password, forKey: "savedPassword")
                    //Transition to the home screen.
                    self.setLoggingIn(false)
                    self.TransitionToHome()
                }
            }
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Helper functions
    //Check the fields and validate the data is correct or not.
    func ValidateFields() -> String? {
        //Check all the fields are filled in.
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
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
            return "Please make sure your password is at least 6 charcters, contains a special charcter and a number."
        }
        //Indicating that nothing went wrong.
        return nil
    }
    func ShowError(_ message: String){
        setLoggingIn(false)
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    //Send the user to home view.
    func TransitionToHome(){
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.StoryBoard.homeViewController)
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}

//
//  LoginViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import FirebaseAuth
import ARKit
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {
    //MARK: Outlets and variables.
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var videoPlayerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User!
    
    //MARK: override funcs.
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElments()
    }
    override func viewWillAppear(_ animated: Bool) {
        //create listner for changes in Authorization state.
        configureAuth()
        //Set the video in the background.
        setUpVideo()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if return is pressed resign first responder to hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Setup funcs.
    func configureAuth(){
        _authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("when did I call?")
            //check if there's a current user.
            if let activeUser = user{
                //Check if the current app user is the FIRUser.
                if self.user != activeUser{
                    self.user = activeUser
                }
            }
            else{
                //User must login in.
            }
        }
    }
    func setUpElments(){
        //Hide the error label.
        errorLabel.alpha = 0
        //Styling the elments
        Utilities.styleTextField(emailTextField, placeHolderString: "Email.")
        Utilities.styleTextField(passwordTextField, placeHolderString: "Password.")
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(backButton)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    func setUpVideo(){
        //Get the path to the resource movie.
        let bandlePath = Bundle.main.path(forResource: "Login", ofType: "mp4")
        guard bandlePath != nil else { return }
        //Create the url from it.
        let url = URL(fileURLWithPath: bandlePath!)
        //Create the video player item.
        let item = AVPlayerItem(url: url)
        //Create the player.
        player = AVQueuePlayer()
        //Create the layer.
        videoPlayerLayer = AVPlayerLayer(player: player!)
        //Add the video in a loop, to be played agian.
        let duration = Int64( ( (Float64(CMTimeGetSeconds(AVAsset(url: url).duration)) *  10.0) - 1) / 10.0 )
        playerLooper = AVPlayerLooper(player: player!, templateItem: item, timeRange: CMTimeRange(start: CMTime.zero, end: CMTimeMake(value: duration, timescale: 1)) )
        //Adjust the size and frame.
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*0.3, y: 0, width: self.view.frame.size.width*1.5, height: self.view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        //Add it to the view and play it.
        player?.playImmediately(atRate: 0.7)
    }
    //Show and hide elments depends on login case.
    func setLoggingIn (_ loggingIn: Bool){
        loggingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        errorLabel.alpha = 0
    }
    
    //MARK: IBACtions funcs.
    //Signing the user.
    @IBAction func loginTapped(_ sender: Any) {
        setLoggingIn(true)
        //close the keyboard.
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        //Create cleaned virsions of data
        let email = self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil{
                //Couldn't sign in.
                self.ShowError(error!.localizedDescription)
            }
            else{
                //Save the user uid.
                UserData.uid = result?.user.uid as! String
                print("User uid: \(UserData.uid)")
                //Save the email and password!
                UserDefaults.standard.set(email, forKey: "savedEmail")
                UserDefaults.standard.set(password, forKey: "savedPassword")
                //Transition to the home screen.
                self.setLoggingIn(false)
                self.TransitionToHome()
            }
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Helper funcs.
    func ShowError(_ message: String){
        setLoggingIn(false)
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    //Send user to the main home view.
    func TransitionToHome(){
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.StoryBoard.homeViewController)
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}

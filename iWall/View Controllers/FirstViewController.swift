//
//  FirstViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import ARKit
import FirebaseAuth

class FirstViewController: UIViewController {
    //MARK: Outlets and variables.
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var welcomLabel: UILabel!
    @IBOutlet weak var signingInLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var videoPlayerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        loggingScreen()
        checkFirstLaunch()
    }
    func loggingScreen(){
        signUpButton.isHidden = true
        loginButton.isHidden = true
        activityIndicator.startAnimating()
    }
    //check if the app has launched before.
    func checkFirstLaunch(){
        print(UserDefaults.standard.bool(forKey: "isFirstLaunch"))
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if !isFirstLaunch {
            //It's not the initial launch of application.
            print("not first time")
            //Check if user already signed in?
            let email = UserDefaults.standard.string(forKey: "savedEmail")
            print(email)
            if email != ""{
                //So, the user is already signed in, get the password and sign in.
                let password = UserDefaults.standard.string(forKey: "savedPassword")
                print(password)
                //login
                Auth.auth().signIn(withEmail: email!, password: password!) { (result, error) in
                    if error != nil{
                        //Couldn't sign in, do nothing and let the user sign manually
                        print("can't sign in")
                    }
                    else{
                        //Transition to the home screen.
                        print("Signed in!")
                        self.TransitionToHome()
                    }
                }
            }
            else{
                //Set the video in the background.
                setUpVideo()
                //Set up elments.
                setUpElments()
            }
        }
        else{
            //Set the video in the background.
            setUpVideo()
            //Set up elments.
            setUpElments()
        }
    }
    func TransitionToHome(){
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.StoryBoard.homeViewController)
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    func setUpElments(){
        //Unhide buttons
        signUpButton.isHidden = false
        loginButton.isHidden = false
        //hide elments
        welcomLabel.isHidden = true
        signingInLabel.isHidden = true
        activityIndicator.stopAnimating()
        //Styling the elments
        Utilities.styleHollowButton(loginButton)
        Utilities.styleFilledButton(signUpButton)
    }
    func setUpVideo(){
        //Get the path to the resource movie.
        let bandlePath = Bundle.main.path(forResource: "FirstVideo", ofType: "mp4")
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
        
        playerLooper = AVPlayerLooper(player: player!, templateItem: item, timeRange: CMTimeRange(start: CMTime.zero, end: CMTimeMake(value: duration, timescale: 1)) )
        
        //Adjust the size and frame.
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*0.3, y: 0, width: self.view.frame.size.width*1.5, height: self.view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        //Add it to the view and play it.
        player?.playImmediately(atRate: 0.7)
    }
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        print("hi?")
    }
}

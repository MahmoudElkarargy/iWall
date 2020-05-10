//
//  HomeViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITextFieldDelegate{
    
    //MARK: Outlets and variables.
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    var ref: DatabaseReference?
    var numberOfImagesToBeLoaded: Int = 0
    var totalnumberOfPages: Int = 1
    var numberOfPage: Int = 1
    var responseGlobal: ImagesSearchResponse?
    var indexOfSelectedImage: Int = 0
    static var isPhotoLiked: Bool = false
    var timer: Timer?
    //MARK: Override funcs.
    override func viewDidLoad() {
        super.viewDidLoad()
        //Bring the activityIndicator in the front!
        self.view.bringSubviewToFront(activityIndicator)
        //Start animating.
        self.activityIndicator.startAnimating()
        //Hide next button.
        nextButton.isHidden = true
        //instance of FIRDatabaseReference.
        ref = Database.database().reference()
        //Add listner.
        ref?.child("users").child(UserData.uid).observe(.value, with: { (snapshot) in
            print("snapShot: \(snapshot)")
            // Get user value
            let value = snapshot.value as? NSDictionary
            UserData.firstName = value?["firstName"] as? String ?? ""
            UserData.lastName = value?["lastName"] as? String ?? ""
            UserData.phoneDevice = value?["deviceType"] as? String ?? ""
            //save all the liked photos urls.
            UserData.photosStorageURL.append(value?["photos"] as? String ?? "")
            print("Now user is: \(UserData.firstName) \(UserData.lastName) and his device: \(UserData.phoneDevice)")
            print("User already have a photos: \(UserData.photosStorageURL)")
            //Set the device.
            self.setUpSelectedDevice()
            if UserData.phoneDevice != ""{
                //Search Automatically for user.
                Client.getPhotosSearchResult(tag: "Wallpaper", minWidth: IPhoneDevices.returnMinWidth(device: UserData.phoneDevice), minHeight: IPhoneDevices.returnMinHeight(device: UserData.phoneDevice),page: self.numberOfPage, completionHandler:
                self.handleImagesSearchResponse(response:error:))
            } else { self.activityIndicator.stopAnimating()}
            }) { (error) in
                print(error.localizedDescription)
            }
        timer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            // check if any Photo has been liked
            if HomeViewController.isPhotoLiked{
                self.collectionView.reloadData()
                HomeViewController.isPhotoLiked = false
            }
        }
        setUpElments()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if return is pressed resign first responder to hide keyboard
        textField.resignFirstResponder()
        //Search when return pressed.
        prepareForSearch()
        return true
    }
    //MARK: Setup funcs.
    fileprivate func setUpSelectedDevice() {
        let selectediPhone = UserData.phoneDevice
        if selectediPhone != ""{
            typeTextField.text = selectediPhone
        }
    }
    //To be called when user liked a photo.
    static func calledFromImageSelectedView(){
        isPhotoLiked = true
    }
    func setUpElments(){
        //load the selected iphone
        setUpSelectedDevice()
        //Hide the error label.
        errorLabel.alpha = 0
        Utilities.styleTextField(typeTextField, placeHolderString: "Select iPhone.")
        Utilities.styleTextField(tagTextField, placeHolderString: "Add tag.")
        //init a pickerView.
        let iPhonePicker = UIPickerView()
        //set up delegates.
        setUpDelegates(iPhonePicker)
        typeTextField.inputView = iPhonePicker
        iPhonePicker.backgroundColor = UIColor.init(red: 31/255, green: 33/255, blue: 36/255, alpha: 1)
        //create tool bar for the pickerView.
        createToolBar()
        //Customization
        customizeCollectionView()
    }
    fileprivate func setUpDelegates(_ iPhonePicker: UIPickerView) {
        typeTextField.delegate = self
        tagTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        iPhonePicker.delegate = self
    }
    fileprivate func customizeCollectionView() {
        //set spacing of cells.
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (self.collectionView.frame.size.width-20)/2, height: (self.collectionView.frame.size.height)/5)
    }
    func createToolBar(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        //Customizations
        toolBar.barTintColor = UIColor.init(red: 35/255, green: 37/255, blue: 41/255, alpha: 0.5)
        toolBar.tintColor = .white
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(HomeViewController.dismissKeyboard))
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        typeTextField.inputAccessoryView = toolBar
    }
    @objc func dismissKeyboard(){
        view.endEditing(true)
        //Search now!
        prepareForSearch()
    }
    //MARK: Helper funcs.
    func prepareForSearch(){
        //hide label.
        errorLabel.alpha = 0
        //Make sure user selected iPhone type.
        if typeTextField.text != "" {
            //Add the tag names to the URL.
            var targetStriing = "Wallpaper"
            //Make sure if user add any tags.
            if tagTextField.text != "" {
                //to be prepared for the url.
                let tagString = tagTextField.text!.replacingOccurrences(of: " ", with: "+")
                //Search with tag!
                targetStriing = targetStriing + "+" + tagString
                print(targetStriing)
            }
            //Search for imgs.
            Client.getPhotosSearchResult(tag: targetStriing, minWidth: IPhoneDevices.returnMinWidth(device: typeTextField.text!), minHeight: IPhoneDevices.returnMinHeight(device: typeTextField.text!), page: self.numberOfPage, completionHandler:
            handleImagesSearchResponse(response:error:))
        } else { ShowMessage("Enter mobile type please.",true)}
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
    
    //MARK: Response func.
    func handleImagesSearchResponse(response: ImagesSearchResponse?, error: Error?){
        guard error == nil , response != nil else {
            ShowMessage("Can't load data",true)
            return
        }
        activityIndicator.startAnimating()
        //Hide next button.
        nextButton.isHidden = true
        //Everthing is good to go!
        responseGlobal = response
        if response!.total > 0{
            //Okay there, pics!
            if response!.total > 10{
                //make sure everypage contains only 10 imgs.
                numberOfImagesToBeLoaded = 10
                totalnumberOfPages = response!.total / 10
            } else{
                numberOfImagesToBeLoaded = response!.total
                totalnumberOfPages = 1
            }
            ShowMessage("Showing \(numberOfImagesToBeLoaded*numberOfPage) of \(response!.total) images.", false)
            collectionView.reloadData()
        }
        else{
            ShowMessage("No images found!",true)
        }
    }
    //MARK: IBAction funcs.
    @IBAction func nextTapped(_ sender: Any) {
        //Still there's more images to search.
        if numberOfPage < totalnumberOfPages{
            //increment to search again.
            numberOfPage = numberOfPage + 1
            //Search for imgs.
            prepareForSearch()
        }
        else {
            nextButton.isHidden = true
        }
    }
}

//MARK: PickerView extension.
extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return IPhoneDevices.devices.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return IPhoneDevices.devices[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = IPhoneDevices.devices[row]
        //Update the dataBase with the user new device.
        self.ref!.child("users/\(UserData.uid)/deviceType").setValue(IPhoneDevices.devices[row])
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        //Customize the pickerView texts.
        var label: UILabel
        if let view = view as? UILabel{
            label = view
        }else{
            label = UILabel()
        }
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Tamil Sangam MN ", size: 20)
        label.text = IPhoneDevices.devices[row]
        return label
    }
}

//MARK: CollectionView extension.
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImagesToBeLoaded
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        //Setting up the cell.
        cell.cellLabel.text = responseGlobal?.hits[indexPath.row].tags
        cell.imageview.image = UIImage(named: "placeholderImage")!
        downloadImage(url: (responseGlobal?.hits[indexPath.row].previewURL)!) { (image) -> Void in
            // display it
            cell.imageview.image = image
            //stop the animating
            self.activityIndicator.stopAnimating()
            //UnHide next button.
            self.nextButton.isHidden = false
        }
        let imageURL = responseGlobal?.hits[indexPath.row].largeImageURL
        print("Checking the url: \(imageURL)")
        if UserData.photos.contains(imageURL!){
            //the user has liked this image.
            cell.loveImage.image = UIImage(named: "liked")!
        }else{
            cell.loveImage.image = UIImage(named: "love")!
        }
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Add a boarder to the selected cell.
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.white.cgColor
        cell?.layer.borderWidth = 3
        //Navigate to see the Image Selected.
        indexOfSelectedImage = indexPath.row
        performSegue(withIdentifier: "selectedImageSegue", sender: nil)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.borderWidth = 0.5
    }
    // this method downloads a huge image on a global queue
    // once finished, the completion closure runs with the image
    func downloadImage(url:String, completionHandler handler: @escaping (UIImage?) -> Void){
        DispatchQueue.global(qos: .userInitiated).async {
            // use url to get the data for the image
            if let url = URL(string: url), let imgData = try? Data(contentsOf: url) {
                // turn data into an image
                let image = UIImage(data: imgData)
                // always run completion handler in the main queue, just in case!
                DispatchQueue.main.async {
                    handler(image)
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedImageSegue"{
            let imageSelectedView = segue.destination as! ImageSelectedViewController
            imageSelectedView.imageURL = responseGlobal?.hits[indexOfSelectedImage].largeImageURL
            imageSelectedView.labelText = responseGlobal?.hits[indexOfSelectedImage].tags
        }
    }
}

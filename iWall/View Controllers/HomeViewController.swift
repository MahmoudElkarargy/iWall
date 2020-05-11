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
    @IBOutlet weak var prevButton: UIButton!
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
        //Hide next and prev button.
        nextButton.isHidden = true
        prevButton.isHidden = true
        addDatabaseListener()
        startTimer()
        setUpElments()
    }
    func addDatabaseListener(){
        //instance of FIRDatabaseReference.
        ref = Database.database().reference()
        //Add listner.
        ref?.child("users").child(UserData.uid).observe(.value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            UserData.firstName = value?["firstName"] as? String ?? ""
            UserData.lastName = value?["lastName"] as? String ?? ""
            UserData.phoneDevice = value?["deviceType"] as? String ?? ""
            //Check if there's photo saved, by counting number of childs.
            //make sure it's trigged after adding the store path and URL
            if snapshot.childrenCount > 3 && snapshot.childrenCount % 2 != 0 {
                //sub. the first 3 child's and then divide by 2.
                let numberOfimages = (snapshot.childrenCount-3)/2
                //delete all saved data before adding new.
                UserData.photosID.removeAll()
                UserData.photosStorageURL.removeAll()
                //Loop to add both Storage path and image url in the UserData.
                for photos in 0...numberOfimages-1{
                    UserData.photosStorageURL.append(value?["photo\(photos)"] as? String ?? "")
                    UserData.photosID.append(value?["photoURL\(photos)"] as? Int ?? 0)
                }
            }
            //Set the device.
            self.setUpSelectedDevice()
            if UserData.phoneDevice != ""{
                //Search Automatically for user.
                self.prepareForSearch()
            } else { self.activityIndicator.stopAnimating()}
            }) { (error) in
                ShowAlert.show(title: "ERROR!", message: "\(error.localizedDescription)", controller: self)
            }
    }
    func startTimer(){
        timer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            // check if any Photo has been liked
            if HomeViewController.isPhotoLiked{
                self.collectionView.reloadData()
                HomeViewController.isPhotoLiked = false
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if return is pressed resign first responder to hide keyboard
        textField.resignFirstResponder()
        //Search when return pressed.
        numberOfPage = 1
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
        //Hide next and prev button.
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
            if numberOfPage == 2{
                prevButton.isHidden = false
            }
            //Search for imgs.
            prepareForSearch()
        }
        else {
            nextButton.isHidden = true
        }
    }
    @IBAction func prevButtonTapped(_ sender: Any) {
        if numberOfPage > 1{
            //increment to search again.
            numberOfPage = numberOfPage - 1
            if numberOfPage == totalnumberOfPages-1{
                nextButton.isHidden = false
            }
            //Search for imgs.
            prepareForSearch()
        }
        else{
            prevButton.isHidden = true
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
        numberOfPage = 1
        prepareForSearch()
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
            //UnHide next and prev button.
            self.nextButton.isHidden = false
        }
        let imageID = responseGlobal?.hits[indexPath.row].id
        if UserData.photosID.contains(imageID!){
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
            imageSelectedView.imageID = responseGlobal?.hits[indexOfSelectedImage].id
        }
    }
}

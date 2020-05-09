//
//  HomeViewController.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/8/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var numberOfImagesToBeLoaded: Int = 0
    var responseGlobal: ImagesSearchResponse?
    var indexOfSelectedImage: Int = 0
//    var selectedImage: UIImage!
//    var selectedTag: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElments()
    }
    func setUpElments(){
        //Hide the error label.
        errorLabel.alpha = 0
        Utilities.styleTextField(typeTextField, placeHolderString: "Select iPhone.")
        Utilities.styleTextField(tagTextField, placeHolderString: "Add tag.")
        typeTextField.delegate = self
        tagTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        //init a pickerView.
        let iPhonePicker = UIPickerView()
        iPhonePicker.delegate = self
        
        typeTextField.inputView = iPhonePicker
        //Customization
        iPhonePicker.backgroundColor = UIColor.init(red: 31/255, green: 33/255, blue: 36/255, alpha: 1)
        
        createToolBar()
        
        //set spacing of cells.
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (self.collectionView.frame.size.width-20)/2, height: (self.collectionView.frame.size.height)/5)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if return is pressed resign first responder to hide keyboard
        textField.resignFirstResponder()
        prepareForSearch()
        return true
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
    func prepareForSearch(){
        
        if typeTextField.text != "" {
            print("Resolution: \(IPhoneDevices.returnMinHeight(device: typeTextField.text!))X\(IPhoneDevices.returnMinWidth(device: typeTextField.text!))")
            var targetStriing = "wallpaper"
            if tagTextField.text != "" {
                let tagString = tagTextField.text!.replacingOccurrences(of: " ", with: "+")
                print(tagString)
                //Search with tag!
                targetStriing = targetStriing + "+" + tagString
                print(targetStriing)
            } else {
                //requist Search without tags!
                print(targetStriing)
            }
            Client.getPhotosSearchResult(tag: targetStriing, minWidth: IPhoneDevices.returnMinWidth(device: typeTextField.text!), minHeight: IPhoneDevices.returnMinHeight(device: typeTextField.text!), completionHandler:
            handleImagesSearchResponse(response:error:))
        } else { ShowError("Enter mobile type please.")}
        
        
    }
    func ShowError(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func handleImagesSearchResponse(response: ImagesSearchResponse?, error: Error?){
        guard error == nil , response != nil else {
            ShowError("Can't load data")
            return
        }
        //Everthing is good to go!
        responseGlobal = response
        print("Tmam search is done.")
        if response!.total > 0{
            //Okay there, pics!
            if response!.total > 10{
                //make sure everypage contains only 10 imgs.
                numberOfImagesToBeLoaded = 10
            } else{
                numberOfImagesToBeLoaded = response!.total
            }
            print("numbers: \(numberOfImagesToBeLoaded)")
            collectionView.reloadData()
        }
        else{
            ShowError("No images found!")
        }
    }
}

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
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("fe eh 3l sobh??????\(numberOfImagesToBeLoaded)")
        return numberOfImagesToBeLoaded
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        print("Setting Cell")
        cell.cellLabel.text = responseGlobal?.hits[indexPath.row].tags
        print("inex: \(indexPath.row)")
        print("url is : \(responseGlobal?.hits[indexPath.row].previewURL)")
        downloadImage(url: (responseGlobal?.hits[indexPath.row].previewURL)!) { (image) -> Void in
            // display it
            cell.imageview.image = image
        }
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.white.cgColor
        cell?.layer.borderWidth = 3
        
        //Navigate to see the Image Selected.
        indexOfSelectedImage = indexPath.row
        print("now index: \(indexOfSelectedImage)")
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
            print("testing url")
            if let url = URL(string: url), let imgData = try? Data(contentsOf: url) {
                print("url is good")
                // turn data into an image
                let image = UIImage(data: imgData)
                print("turned into image")
                // always run completion handler in the main queue, just in case!
                DispatchQueue.main.async {
                    print("return itt")
                    handler(image)
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedImageSegue"{
            print("Eh el klam??")
            let imageSelectedView = segue.destination as! ImageSelectedViewController
            imageSelectedView.imageURL = responseGlobal?.hits[indexOfSelectedImage].largeImageURL
            imageSelectedView.labelText = responseGlobal?.hits[indexOfSelectedImage].tags
            print("url is : \(responseGlobal?.hits[indexOfSelectedImage].largeImageURL)")
            
        }
    }
    
}

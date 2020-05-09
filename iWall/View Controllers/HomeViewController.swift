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
        //init a pickerView.
        let iPhonePicker = UIPickerView()
        iPhonePicker.delegate = self
        
        typeTextField.inputView = iPhonePicker
        //Customization
        iPhonePicker.backgroundColor = UIColor.init(red: 59/255, green: 197/255, blue: 238/255, alpha: 1)
        
        createToolBar()
        
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
        toolBar.barTintColor = UIColor.init(red: 59/255, green: 197/255, blue: 238/255, alpha: 0.5)
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
            Client.getPhotosSearchResult(tag: targetStriing, minWidth: IPhoneDevices.returnMinWidth(device: typeTextField.text!), minHeight: IPhoneDevices.returnMinHeight(device: typeTextField.text!)) { (bool, error) in
                        print("edaa")
            }
        } else { ShowError("Enter mobile type please.")}
        
        
    }
    func ShowError(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
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

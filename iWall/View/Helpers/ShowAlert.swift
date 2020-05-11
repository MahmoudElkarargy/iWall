//
//  ShowAlert.swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/11/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import Foundation
import UIKit

class ShowAlert{
    
    // MARK: Display Error Message to the User
    static func show(title: String, message: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okButton)
        controller.present(alertController, animated: true, completion: nil)
    }
}

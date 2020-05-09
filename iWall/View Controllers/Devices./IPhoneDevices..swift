//
//  iPhoneDevices..swift
//  iWall
//
//  Created by Mahmoud Elkarargy on 5/9/20.
//  Copyright © 2020 Mahmoud Elkarargy. All rights reserved.
//

import Foundation

class IPhoneDevices{
    static let devices = ["iPhone(2007)", "iPhone 3G",
    "iPhone 3GS", "iPhone 4",
    "iPhone 4s", "iPhone 5",
    "iPhone 5c", "iPhone 5s",
    "iPhone SE (1nd generation)", "iPhone 6 Plus",
    "iPhone 6", "iPhone 6s Plus",
    "iPhone 6s","iPhone 7 Plus",
    "iPhone 7", "iPhone 8 Plus",
    "iPhone 8", "iPhone X",
    "iPhone XR", "iPhone XS Max",
    "iPhone XS", "iPhone 11",
    "iPhone 11 Pro Max", "iPhone 11 Pro",
    "iPhone SE (2nd generation)"]
    
    
    static func returnMinWidth(device: String) -> Int{
        switch device {
        case "iPhone(2007)", "iPhone 3G", "iPhone 3GS":
            return 320
        case "iPhone 4", "iPhone 4s", "iPhone 5",
        "iPhone 5c", "iPhone 5s", "iPhone SE (1nd generation)":
            return 640
        case "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone SE (2nd generation)":
            return 750
        case "iPhone XR", "iPhone 11":
            return 828
        case "iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus":
            return 1080
        case "iPhone X", "iPhone XS", "iPhone 11 Pro":
            return 1125
        case "iPhone XS Max", "iPhone 11 Pro Max":
            return 1242
        default:
            return 1
        }
    }
    static func returnMinHeight(device: String) -> Int{
        switch device {
        case "iPhone(2007)", "iPhone 3G", "iPhone 3GS":
            return 480
        case "iPhone 4", "iPhone 4s":
            return 960
        case "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone SE (1nd generation)":
            return 1136
        case "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone SE (2nd generation)":
            return 1334
        case "iPhone XR", "iPhone 11":
            return 1792
        case "iPhone 6 Plus", "iPhone 6s Plus", "iPhone 7 Plus", "iPhone 8 Plus":
            return 1920
        case "iPhone X", "iPhone XS", "iPhone 11 Pro":
            return 2436
        case "iPhone XS Max", "iPhone 11 Pro Max":
            return 2688
        default:
            return 1
        }
    }
}

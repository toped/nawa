//
//  GlobalConstants.swift
//  Directory
//
//  Created by TopeD on 1/11/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import Foundation
import UIKit

struct GlobalConstants {
    
    //TableViewCell Identifiers
    static let WEATHER_CELL_IDENTIFIER = "WEATHER_CELL"
    
    //OPEN WEATHER API KEY
    static let OPEN_WEATHER_API_KEY    = "5fb7b2d5da9055f9f6c025c47cf94ec9"
    
    static func uicolorFromHex(rgbValue:UInt32)->UIColor{
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
        
    }
    
}
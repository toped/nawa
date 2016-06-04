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
    //NSUserDefaults Keys
    static let CITIES_KEY               = "CITIES_KEY"
    static let STATES_KEY               = "STATES_KEY"
    static let PRIMARY_CITY_KEY         = "PRIMARY_CITY_KEY"
    static let PRIMARY_STATE_KEY        = "PRIMARY_STATE_KEY"
    static let SECONDARY_CITY_KEY       = "SECONDARY_CITY_KEY"
    static let SECONDARY_STATE_KEY      = "SECONDARY_STATE_KEY"
    static let TERTIARY_CITY_KEY        = "TERTIARY_CITY_KEY"
    static let TERTIARY_STATE_KEY       = "TERTIARY_STATE_KEY"

    //TableViewCell Identifiers
    static let WEATHER_CELL_IDENTIFIER  = "WEATHER_CELL"
    static let CITY_CELL_IDENTIFIER     = "CITY_CELL"
    static let STATE_CELL_IDENTIFIER    = "STATE_CELL"
    
    //OPEN WEATHER API KEY
    static let OPEN_WEATHER_API_KEY     = "5fb7b2d5da9055f9f6c025c47cf94ec9"
    
    static func uicolorFromHex(rgbValue:UInt32)->UIColor{
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
        
    }
    
}
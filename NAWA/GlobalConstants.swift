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
    
    //NSUSerDefaults Keys
    static let COUNTY_OFFICES_KEY = "county_offices_key"
    static let COUNTY_AGENTS_KEY = "county_agents_key"
    static let REGIONS_KEY = "regions_key"
    static let CTOAPPS_KEY = "ctoapps_key"
    
    //TableViewCell Identifiers
    static let WEATHER_CELL_IDENTIFIER = "WEATHER_CELL"
    static let APP_CELL_IDENTIFIER = "app_cell"
    static let DETAIL_HEADER_CELL_IDENTIFIER = "detail_header_cell"
    static let STAFF_CONTACT_CELL_IDENTIFIER = "staff_contact_cell"
    
    //Segue Identifiers
    static let SHOW_OFFICE_DETAILS_IDENTIFIER = "show_office_details"
    static let SHOW_STAFF_DETAILS_IDENTIFIER = "show_staff_details"
    static let SHOW_FILTERED_STAFF_IDENTIFIER = "show_filtered_staff"
    static let SHOW_DISTRICT_OFFICES_IDENTIFIER = "show_district_offices"
    
    static func uicolorFromHex(rgbValue:UInt32)->UIColor{
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
        
    }
    
}
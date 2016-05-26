//
//  City.swift
//  NAWA
//
//  Created by Tope Daramola on 5/25/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import Foundation

class City: NSObject, NSCoding {
    
    var name:String = "N/A"
    var stateAbbriviation:String = "N/A"
    var latitude:String = "N/A"
    var longitude:String = "N/A"
    
    override init() {
        super.init()
    }
    
    init(name:String, stateAbbriviation:String, latitude:String, longitude:String) {
        
        self.name = name
        self.stateAbbriviation = stateAbbriviation
        self.latitude = latitude
        self.longitude = longitude
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObjectForKey("name") as! String
        let stateAbbriviation = aDecoder.decodeObjectForKey("stateAbbriviation") as! String
        let latitude = aDecoder.decodeObjectForKey("latitude") as! String
        let longitude = aDecoder.decodeObjectForKey("longitude") as! String
        
        self.init(
            name:name,
            stateAbbriviation:stateAbbriviation,
            latitude:latitude,
            longitude:longitude
        )
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(stateAbbriviation, forKey: "stateAbbriviation")
        aCoder.encodeObject(latitude, forKey: "latitude")
        aCoder.encodeObject(longitude, forKey: "longitude")
        
    }
    
}

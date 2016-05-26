//
//  State.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import Foundation

class State: NSObject, NSCoding {
    
    var name:String = "N/A"
    var stateAbbriviation:String = "N/A"
    var latitude:String = "N/A"
    var longitude:String = "N/A"
    
    override init() {
        super.init()
    }
    
    init(name:String, stateAbbriviation:String) {
        
        self.name = name
        self.stateAbbriviation = stateAbbriviation
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObjectForKey("name") as! String
        let stateAbbriviation = aDecoder.decodeObjectForKey("stateAbbriviation") as! String

        self.init(
            name:name,
            stateAbbriviation:stateAbbriviation
        )
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(stateAbbriviation, forKey: "stateAbbriviation")

    }
    
}

//
//  State.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import Foundation

class State: NSObject, NSCoding {
    
    @objc var name:String = "N/A"
    @objc var stateAbbriviation:String = "N/A"
    @objc var latitude:String = "N/A"
    @objc var longitude:String = "N/A"
    
    override init() {
        super.init()
    }
    
    @objc init(name:String, stateAbbriviation:String) {
        
        self.name = name
        self.stateAbbriviation = stateAbbriviation
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let stateAbbriviation = aDecoder.decodeObject(forKey: "stateAbbriviation") as! String

        self.init(
            name:name,
            stateAbbriviation:stateAbbriviation
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(stateAbbriviation, forKey: "stateAbbriviation")

    }
    
}

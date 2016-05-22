//
//  OpenWeather.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class OpenWeather: NSObject {
    
    var apiKey:String = "N/A"

    
    override init() {
        super.init()
    }
    
    init(apiKey:String) {
        
        self.apiKey = apiKey
        
    }
    
    
    func getCurrentWeather(city: String, state: String, completion: (result: Any, success: Bool) -> Void) {
        
        let URL = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=" + self.apiKey)!
        print("got back: \(URL)")
        let URLRequest = NSMutableURLRequest(URL: URL)
        URLRequest.cachePolicy = .ReloadIgnoringCacheData
        
        Alamofire.request(URLRequest).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            if response.response != nil {
                /* If get a response form the server */
                completion(result:response, success:true)

                
            }
            else {
                /* If we don't get a response form the server (or no internet connection) */
                completion(result:"No response!", success:false)

                
            }
        }
    }
}

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
    
    
    func getCurrentWeather(city: String, state: String, completion: (result: WeatherCondition?, success: Bool) -> Void) {
        
        let url : String = "http://api.openweathermap.org/data/2.5/weather?q=\(city), \(state)&appid=\(self.apiKey)"
        let urlStr : String = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        //let searchURL : NSURL = NSURL(string: urlStr as String)!

        let searchURL : NSURL = NSURL(string: urlStr)!
        
        print("got back: \(searchURL)")
        print("got back: \(searchURL)")
        let URLRequest = NSMutableURLRequest(URL: searchURL)
        URLRequest.cachePolicy = .ReloadIgnoringCacheData
        
        Alamofire.request(URLRequest).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                let response = JSON as! [String: AnyObject]
                
                guard let currentWeather = response["main"] as? [String: AnyObject],
                    let currentTemp = currentWeather["temp"],
                    let currentTempMin = currentWeather["temp_min"],
                    let currentTempMax = currentWeather["temp_max"] else {
                        print("Request parse failed with gaurd error")
                        return;
                }
                print(currentTemp)
                
                let weatherConditions = WeatherCondition.init(city: city, state: state, description:"", temperature:"\(currentTemp)", temperatureMin:"\(currentTempMin)", temperatureMax:"\(currentTempMax)")
                
                completion(result:weatherConditions, success:true)
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
                completion(result:nil, success:false)
                
            }

            
        }
    }
}

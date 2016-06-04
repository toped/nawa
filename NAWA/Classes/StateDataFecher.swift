//
//  StateDataFecher.swift
//  NAWA
//
//  Created by Tope Daramola on 5/24/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit
import Alamofire

class StateDataFecher: NSObject {
    
    override init() {
        super.init()
    }
    
    
    func getCitiesForState(state: String, completion: (result: [City]?, success: Bool) -> Void) {
        
        let URL = NSURL(string: "http://topedaramola.com/apis/worlds/apiv1/state/index?method=getCitiesForState&state_abbr=" + state)!
        print("got back: \(URL)")
        let URLRequest = NSMutableURLRequest(URL: URL)
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
                let resoinseCities = response["Cities"] as! NSArray
                var cities = [City]()
                
                for item in resoinseCities {
                   
                    guard let name = item["city"] as? String,
                        let latitude = item["latitude"] as? Float,
                        let longitude = item["longitude"] as? Float else {
                            print("un-successful");
                            return;
                    }
                    
                    let currentCity = City.init(name: name, stateAbbriviation: state, latitude: "\(latitude)", longitude: "\(longitude)")
                    cities.append(currentCity)
                    
                }
                
                completion(result:cities, success:true)

                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
                completion(result:nil, success:false)

            }

        }
    }

}

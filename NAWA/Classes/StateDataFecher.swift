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
    
    
    func getCitiesForState(state: String, completion: @escaping (_ result: [City]?, _ success: Bool) -> Void) {
        
        let URL = "http://topedaramola.com/apis/worlds/apiv1/state/?method=getCitiesForState&state_abbr=" + state
        print("got back: \(URL)")
        
        Alamofire.request(URL, method: HTTPMethod.get, encoding: JSONEncoding.default).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            switch response.result {
            case .success(let JSON):
                //print("Success with JSON: \(JSON)")
                
                let response = JSON as! [String: AnyObject];
                let resoinseCities = response["Cities"] as! NSArray
                var cities = [City]()
                
                for item in resoinseCities {
                   let item = item as! [String : Any]
                    
                    guard let name = item["city"] as? String,
                        let latitude = item["latitude"] as? Float,
                        let longitude = item["longitude"] as? Float else {
                            print("un-successful");
                            return;
                    }
                    
                    let currentCity = City.init(name: name, stateAbbriviation: state, latitude: "\(latitude)", longitude: "\(longitude)")
                    cities.append(currentCity)
                    
                }
                
                completion(cities, true)

                
            case .failure(let error):
                print("Request failed with error: \(error)")
                
                completion(nil, false)

            }

        }
    }

}

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
    
    
    func getCurrentWeather(city: String, state: String, latitude: String, longitude: String, completion: @escaping (_ result: WeatherCondition?, _ success: Bool) -> Void) {
        
        let URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(self.apiKey)"
        let URLstr = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        print(URLstr)
        Alamofire.request(URLstr, method: HTTPMethod.get, encoding: JSONEncoding.default).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            switch response.result {
            case .success(let JSON):
                //print("Success with JSON: \(JSON)")
                
                let response = JSON as! [String: AnyObject]
                
                guard let currentWeather = response["main"],
                    let currentTemp = currentWeather["temp"],
                    let currentTempMin = currentWeather["temp_min"],
                    let currentTempMax = currentWeather["temp_max"] else {
                        print("Request parse failed with gaurd error")
                        return;
                }
                
                
                guard let weather = response["weather"] as? [AnyObject],
                    let icon = weather[0]["icon"] else {
                        print("Request parse failed with gaurd error")
                        return;
                }
                
                //print(currentTemp)
                let weatherConditions = WeatherCondition.init(city: city, state: state, latitude: latitude, longitude: longitude, description: "", mainIcon: icon as! String, temperature: "\(currentTemp!)", temperatureMin: "\(currentTempMin!)", temperatureMax: "\(currentTempMax!)")
                
                completion(weatherConditions, true)
                
                
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                
                completion(nil, false)
                
            }

            
        }
    }
    
    
    func get5DayForcast(city: String, state: String, latitude: String, longitude: String, completion: @escaping (_ result: [DailyForecast]?, _ success: Bool) -> Void) {
        
        let url : String = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&appid=\(self.apiKey)"
        let urlStr : String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        Alamofire.request(urlStr, method: HTTPMethod.get, encoding: JSONEncoding.default).responseJSON { response in
            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            switch response.result {
            case .success(let JSON):
                //print("Success with JSON: \(JSON)")
                
                let response = JSON as! [String: AnyObject]
                let forecasts = response["list"] as! NSArray
                
                var dailyForecasts = [DailyForecast]()
                
                for item in forecasts {
                    let item = item as! [String : Any]

                    let currentDay = item["dt"] as! Double
                    let date = NSDate(timeIntervalSince1970: currentDay)

                    let usDateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE", options: 0, locale: NSLocale(localeIdentifier: "en-US") as Locale)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = usDateFormat
                    let usSwiftDayString = formatter.string(from: date as Date)
                    
                    
                    guard let currentTemp = item["temp"] as? [String: AnyObject],
                        let currentTempDay = currentTemp["day"],
                        let currentTempMin = currentTemp["min"],
                        let currentTempMax = currentTemp["max"] else {
                            print("Request parse failed with gaurd error")
                            return;
                    }
                    
                    let weather = item["weather"] as! NSArray

                    guard let weatherList = weather.object(at: 0) as? [String: AnyObject],
                        let icon = weatherList["icon"] else {
                            print("Request parse failed with gaurd error")
                            return;
                    }
                    
                    let forcast = DailyForecast.init(day: usSwiftDayString, description:"", mainIcon:icon as! String, temperature:"\(currentTempDay)", temperatureMin:"\(currentTempMin)", temperatureMax:"\(currentTempMax)")
                    
                    dailyForecasts.append(forcast)
                    //print(usSwiftDayString)

                }
            
                completion(dailyForecasts, true)

                
            case .failure(let error):
                print("Request failed with error: \(error)")
                
                completion(nil, false)
                
            }
            
            
        }
    }

}

//
//  DailyForecast.swift
//  NAWA
//
//  Created by Tope Daramola on 6/4/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit

class DailyForecast: NSObject, NSCoding {
    
    @objc var day:String = "N/A"
    @objc var weatherDescription:String = "N/A"
    @objc var mainIcon:String = "N/A"
    
    //kelvins
    @objc var temperature:String = "0"
    @objc var temperatureMin:String = "0"
    @objc var temperatureMax:String = "0"
    
    //fahrenheit
    @objc var temperature_fahrenheit:String = "0"
    @objc var temperatureMin_fahrenheit:String = "0"
    @objc var temperatureMax_fahrenheit:String = "0"
    
    //celsius
    @objc var temperature_celsius:String = "0"
    @objc var temperatureMin_celsius:String = "0"
    @objc var temperatureMax_celsius:String = "0"
    
    override init() {
        super.init()
        
    }
    
    @objc init(day:String, description:String, mainIcon:String, temperature:String, temperatureMin:String, temperatureMax:String) {
        super.init()
        
        self.day = day
        self.weatherDescription = description
        self.temperature = temperature
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.mainIcon = mainIcon
        
        self.getTemperatureInFahrenheit()
        self.getTemperatureInCelsius()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let day = aDecoder.decodeObject(forKey: "day") as! String
        let weatherDescription = aDecoder.decodeObject(forKey:"weatherDescription") as! String
        let temperature = aDecoder.decodeObject(forKey:"temperature") as! String
        let temperatureMin = aDecoder.decodeObject(forKey:"temperatureMin") as! String
        let temperatureMax = aDecoder.decodeObject(forKey:"temperatureMax") as! String
        let mainIcon = aDecoder.decodeObject(forKey: "mainIcon") as! String
        
        self.init(
            day:day,
            description:weatherDescription,
            mainIcon:mainIcon,
            temperature:temperature,
            temperatureMin:temperatureMin,
            temperatureMax:temperatureMax
        )
    }
    
    func encode(with aCoder: NSCoder) {

        aCoder.encode(day, forKey: "day")
        aCoder.encode(weatherDescription, forKey: "weatherDescription")
        aCoder.encode(mainIcon, forKey: "mainIcon")
        aCoder.encode(temperature, forKey: "temperature")
        aCoder.encode(temperatureMin, forKey: "temperatureMin")
        aCoder.encode(temperatureMax, forKey: "temperatureMax")
        
    }
    
    @objc func getTemperatureInFahrenheit() {
        //T(°F) = T(K) × 9/5 - 459.67
        
        self.temperature_fahrenheit = String(format: "%.0f", (Double(self.temperature)! * 9/5 - 459.67))
        self.temperatureMin_fahrenheit = String(format: "%.0f", (Double(self.temperatureMin)! * 9/5 - 459.67))
        self.temperatureMax_fahrenheit = String(format: "%.0f", (Double(self.temperatureMax)! * 9/5 - 459.67))
    }
    
    @objc func getTemperatureInCelsius() {
        //T(°C) = T(K) - 273.15
        
        self.temperature_celsius = String(format: "%.0f", (Double(self.temperature)! - 273.15))
        self.temperatureMin_celsius = String(format: "%.0f", (Double(self.temperatureMin)! - 273.15))
        self.temperatureMax_celsius = String(format: "%.0f", (Double(self.temperatureMax)! - 273.15))
    }
    
}

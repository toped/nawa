//
//  WeatherCondition.swift
//  NAWA
//
//  Created by Tope Daramola on 5/26/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit

class WeatherCondition: NSObject, NSCoding {
    
    var cityName:String = "N/A"
    var stateAbbreiviation:String = "N/A"
    var weatherDescription:String = "N/A"
    
    //kelvins
    var temperature:String = "0"
    var temperatureMin:String = "0"
    var temperatureMax:String = "0"
    
    //fahrenheit
    var temperature_fahrenheit:String = "0"
    var temperatureMin_fahrenheit:String = "0"
    var temperatureMax_fahrenheit:String = "0"
    
    //celsius
    var temperature_celsius:String = "0"
    var temperatureMin_celsius:String = "0"
    var temperatureMax_celsius:String = "0"
    
    override init() {
        super.init()

    }
    
    init(city:String, state:String, description:String, temperature:String, temperatureMin:String, temperatureMax:String) {
        super.init()
        
        self.cityName = city
        self.stateAbbreiviation = state
        self.weatherDescription = description
        self.temperature = temperature
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        
        self.getTemperatureInFahrenheit()
        self.getTemperatureInCelsius()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let cityName = aDecoder.decodeObjectForKey("cityName") as! String
        let stateAbbreiviation = aDecoder.decodeObjectForKey("stateAbbreiviation") as! String
        let weatherDescription = aDecoder.decodeObjectForKey("weatherDescription") as! String
        let temperature = aDecoder.decodeObjectForKey("temperature") as! String
        let temperatureMin = aDecoder.decodeObjectForKey("temperatureMin") as! String
        let temperatureMax = aDecoder.decodeObjectForKey("temperatureMax") as! String
        
        self.init(
            city:cityName,
            state:stateAbbreiviation,
            description:weatherDescription,
            temperature:temperature,
            temperatureMin:temperatureMin,
            temperatureMax:temperatureMax
        )
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(cityName, forKey: "cityName")
        aCoder.encodeObject(stateAbbreiviation, forKey: "stateAbbreiviation")
        aCoder.encodeObject(weatherDescription, forKey: "weatherDescription")
        aCoder.encodeObject(temperature, forKey: "temperature")
        aCoder.encodeObject(temperatureMin, forKey: "temperatureMin")
        aCoder.encodeObject(temperatureMax, forKey: "temperatureMax")
        
    }
    
    func getTemperatureInFahrenheit() {
        //T(°F) = T(K) × 9/5 - 459.67
        
        self.temperature_fahrenheit = String(format: "%.0f", (Double(self.temperature)! * 9/5 - 459.67))
        self.temperatureMin_fahrenheit = String(format: "%.0f", (Double(self.temperatureMin)! * 9/5 - 459.67))
        self.temperatureMax_fahrenheit = String(format: "%.0f", (Double(self.temperatureMax)! * 9/5 - 459.67))
    }
    
    func getTemperatureInCelsius() {
        //T(°C) = T(K) - 273.15
        
        self.temperature_celsius = String(format: "%.0f", (Double(self.temperature)! - 273.15))
        self.temperatureMin_celsius = String(format: "%.0f", (Double(self.temperatureMin)! - 273.15))
        self.temperatureMax_celsius = String(format: "%.0f", (Double(self.temperatureMax)! - 273.15))
    }
    
}

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
    var latitude:String = "N/A"
    var longitude:String = "N/A"
    var weatherDescription:String = "N/A"
    var mainIcon:String = "N/A"
    
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
    
    init(city:String, state:String, latitude:String, longitude:String, description:String, mainIcon:String, temperature:String, temperatureMin:String, temperatureMax:String) {
        super.init()
        
        self.cityName = city
        self.stateAbbreiviation = state
        self.latitude = latitude
        self.longitude = longitude
        self.weatherDescription = description
        self.temperature = temperature
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.mainIcon = mainIcon

        self.getTemperatureInFahrenheit()
        self.getTemperatureInCelsius()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let cityName = aDecoder.decodeObject(forKey: "cityName") as! String
        let stateAbbreiviation = aDecoder.decodeObject(forKey: "stateAbbreiviation") as! String
        let latitude = aDecoder.decodeObject(forKey: "latitude") as! String
        let longitude = aDecoder.decodeObject(forKey: "longitude") as! String
        let weatherDescription = aDecoder.decodeObject(forKey: "weatherDescription") as! String
        let temperature = aDecoder.decodeObject(forKey: "temperature") as! String
        let temperatureMin = aDecoder.decodeObject(forKey: "temperatureMin") as! String
        let temperatureMax = aDecoder.decodeObject(forKey: "temperatureMax") as! String
        let mainIcon = aDecoder.decodeObject(forKey: "mainIcon") as! String
        
        self.init(
            city:cityName,
            state:stateAbbreiviation,
            latitude:latitude,
            longitude:longitude,
            description:weatherDescription,
            mainIcon:mainIcon,
            temperature:temperature,
            temperatureMin:temperatureMin,
            temperatureMax:temperatureMax
        )
    }
    
    func encode(with aCoder: NSCoder) {

        aCoder.encode(cityName, forKey: "cityName")
        aCoder.encode(stateAbbreiviation, forKey: "stateAbbreiviation")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(weatherDescription, forKey: "weatherDescription")
        aCoder.encode(mainIcon, forKey: "mainIcon")
        aCoder.encode(temperature, forKey: "temperature")
        aCoder.encode(temperatureMin, forKey: "temperatureMin")
        aCoder.encode(temperatureMax, forKey: "temperatureMax")
        
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

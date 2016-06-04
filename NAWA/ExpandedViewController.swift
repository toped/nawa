//
//  ExpandedViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit

protocol ExpandedCellDelegate: class {
    func expandedCellWillCollapse()
}

class ExpandedViewController: UIViewController {
    
    weak var delegate:ExpandedCellDelegate?
    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var bottomCell: UIView!
    @IBOutlet weak var locationBackgroundImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var mainWeatherIcon: UIImageView!
    var currentWeatherConditions = WeatherCondition?()
    
    //5-day forecast
    @IBOutlet weak var day1Label: UILabel!
    @IBOutlet weak var day2Label: UILabel!
    @IBOutlet weak var day3Label: UILabel!
    @IBOutlet weak var day4Label: UILabel!
    @IBOutlet weak var day5Label: UILabel!
    @IBOutlet weak var day1Icon: UIImageView!
    @IBOutlet weak var day2Icon: UIImageView!
    @IBOutlet weak var day3Icon: UIImageView!
    @IBOutlet weak var day4Icon: UIImageView!
    @IBOutlet weak var day5Icon: UIImageView!
    @IBOutlet weak var day1Temp: UILabel!
    @IBOutlet weak var day2Temp: UILabel!
    @IBOutlet weak var day3Temp: UILabel!
    @IBOutlet weak var day4Temp: UILabel!
    @IBOutlet weak var day5Temp: UILabel!
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.currentTemperatureLabel.text = "\(self.currentWeatherConditions!.temperature_fahrenheit)°F"
        self.mainWeatherIcon.image = UIImage(named:"\(self.currentWeatherConditions!.mainIcon).png")
        
        // get 5-day forcast
        self.getForecast(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationBackgroundImage.clipsToBounds = true
        
    }

    @IBAction func collapseBackToTableView(sender: AnyObject) {
        
        delegate!.expandedCellWillCollapse()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getForecast(sender: AnyObject) {
        
        let openWeatherService = OpenWeather.init(apiKey:GlobalConstants.OPEN_WEATHER_API_KEY)
        
        //get primary weather
        openWeatherService.get5DayForcast((self.currentWeatherConditions?.cityName)!, state:(self.currentWeatherConditions?.stateAbbreiviation)!) { (result, success) in
            if success {
                
                print(result!)
                
                let day1Forecast = result![1] as DailyForecast
                let day2Forecast = result![2] as DailyForecast
                let day3Forecast = result![3] as DailyForecast
                let day4Forecast = result![4] as DailyForecast
                let day5Forecast = result![5] as DailyForecast
                
                // Update the UI
                self.day1Label.text = day1Forecast.day
                self.day2Label.text = day2Forecast.day
                self.day3Label.text = day3Forecast.day
                self.day4Label.text = day4Forecast.day
                self.day5Label.text = day5Forecast.day
                
                self.day1Icon.image = UIImage(named:"\(day1Forecast.mainIcon).png")
                self.day2Icon.image = UIImage(named:"\(day2Forecast.mainIcon).png")
                self.day3Icon.image = UIImage(named:"\(day3Forecast.mainIcon).png")
                self.day4Icon.image = UIImage(named:"\(day4Forecast.mainIcon).png")
                self.day5Icon.image = UIImage(named:"\(day5Forecast.mainIcon).png")
                
                self.day1Temp.text = "\(day1Forecast.temperatureMax_fahrenheit)°F/\(day1Forecast.temperatureMin_fahrenheit)°F"
                self.day2Temp.text = "\(day2Forecast.temperatureMax_fahrenheit)°F/\(day2Forecast.temperatureMin_fahrenheit)°F"
                self.day3Temp.text = "\(day3Forecast.temperatureMax_fahrenheit)°F/\(day3Forecast.temperatureMin_fahrenheit)°F"
                self.day4Temp.text = "\(day4Forecast.temperatureMax_fahrenheit)°F/\(day4Forecast.temperatureMin_fahrenheit)°F"
                self.day5Temp.text = "\(day5Forecast.temperatureMax_fahrenheit)°F/\(day5Forecast.temperatureMin_fahrenheit)°F"
                
            }
            else {
                //There was an error getting primary location weather conditions
            }
            
        }
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

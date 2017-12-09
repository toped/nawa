//
//  WeatherCardsViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit
import CoreLocation


class WeatherCardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, ExpandedCellDelegate, EditLocationDelegate {
    
    
    var locationManager:CLLocationManager!
    
    var weatherLocations = [String]()
    var chosenCellFrame = CGRect()
    var expander: ExpandedViewController?
    var currentPrimaryConditions = WeatherCondition()
    var currentSecondaryConditions = WeatherCondition()
    var currentTertiaryConditions = WeatherCondition()
    var editingPrimary = false
    var editingSecondary = false
    var editingTertiary = false
    
    @IBOutlet weak var weatherCardsTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getWeather(sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        weatherLocations = ["\(self.currentPrimaryConditions.cityName), \(self.currentPrimaryConditions.stateAbbreiviation)",
            "\(self.currentSecondaryConditions.cityName), \(self.currentSecondaryConditions.stateAbbreiviation)",
                            "\(self.currentTertiaryConditions.cityName), \(self.currentTertiaryConditions.stateAbbreiviation)"];
        
        self.edgesForExtendedLayout = []
        self.navigationItem.title = "NAWA"
        
        //re-configureUI Appearance
        self.configureUI()
        
        //Show the navigation bar
        self.navigationController?.isNavigationBarHidden = false
        
        //hide the back button
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain,
                                         target: navigationController,
                                         action: nil)
        
        navigationItem.leftBarButtonItem = backButton
        
        //set right bar button
        let changeLocationBtn = UIBarButtonItem(image: UIImage(named: "refresh-btn")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal),
                                                style: UIBarButtonItemStyle.plain,
                                                target: self,
                                                action: #selector(self.refreshWeather))
        
        let currentLocationBtn = UIBarButtonItem(image: UIImage(named: "current-location-btn")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal),
                                                 style: UIBarButtonItemStyle.plain,
                                                 target: self,
                                                 action: #selector(self.getWeatherAtLocation))
        
        navigationItem.rightBarButtonItems = [changeLocationBtn, currentLocationBtn]
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        self.getWeather(sender: self)
    }
    
    func configureLocationServices() {
        
        //Set up the location services
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = 10; // 10m
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    //self.currentLat = "\(self.locationManager.location?.coordinate.latitude)"
                    //self.currentLon = "\(self.locationManager.location?.coordinate.longitude)"
                    
                    if GlobalConstants.hasConnectivity() {
                        
                        let geocoder = CLGeocoder()
                        geocoder.reverseGeocodeLocation(self.locationManager.location!, completionHandler: { (placemarks, e) -> Void in
                            if e != nil {
                                print("Error:  \(e!.localizedDescription)")
                            } else {
                                let placemark = placemarks!.last! as CLPlacemark
                                
                                let userDefaults = UserDefaults.standard
                                userDefaults.set(placemark.locality, forKey:GlobalConstants.PRIMARY_CITY_KEY)
                                userDefaults.set(placemark.administrativeArea, forKey:GlobalConstants.PRIMARY_STATE_KEY)
                                
                                userDefaults.set(true, forKey: GlobalConstants.USING_CURRENT_LOCATION)
                                userDefaults.synchronize()
                                
                                self.weatherLocations[0] = "\(placemark.locality!), \(placemark.administrativeArea!)"
                                
                                self.getWeather(sender: self)
                                
                            }
                        })
                    }
                    else {
                        
                        let alertController = UIAlertController(title: "Connection Error", message: "Please make sure you are connected to the internet and try again later.", preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                            // ...
                        }
                        alertController.addAction(cancelAction)
                        
                        self.present(alertController, animated: true) {
                            // ...
                        }
                        
                        
                    }
                    
                }
            }
        }
    }
    
    @objc func refreshWeather() {
        
        self.expandedCellWillCollapse()
        
        self.getWeather(sender: self)
        
    }
    
    @objc func getWeatherAtLocation() {
        
        let alertController = UIAlertController(title: "Update Primary Location", message: "Would you like to update primary weather using your current location?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            if (self.expander != nil) {
                self.expandedCellWillCollapse()
            }
            
            self.configureLocationServices()
            return
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
        
    }
    
    func configureUI() {
        
        //View controller-based status bar appearance added to Info.plist
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        
        
    }
    
    func getWeather(sender: AnyObject) {
        
        let openWeatherService = OpenWeather.init(apiKey:GlobalConstants.OPEN_WEATHER_API_KEY)
        
        let userDefaults = UserDefaults.standard
        
        if GlobalConstants.hasConnectivity() {
            
            //get primary weather
            openWeatherService.getCurrentWeather(city: userDefaults.string(forKey: GlobalConstants.PRIMARY_CITY_KEY)!, state:userDefaults.string(forKey: GlobalConstants.PRIMARY_STATE_KEY)!, latitude: userDefaults.string(forKey: GlobalConstants.PRIMARY_LAT_KEY)!, longitude: userDefaults.string(forKey: GlobalConstants.PRIMARY_LON_KEY)!) { (result, success) in
                if success {
                    
                    self.currentPrimaryConditions = result!
                    
                    //get secondary weather
                    openWeatherService.getCurrentWeather(city: userDefaults.string(forKey: GlobalConstants.SECONDARY_CITY_KEY)!, state:userDefaults.string(forKey: GlobalConstants.SECONDARY_STATE_KEY)!, latitude: userDefaults.string(forKey: GlobalConstants.SECONDARY_LAT_KEY)!, longitude: userDefaults.string(forKey: GlobalConstants.SECONDARY_LON_KEY)!) { (result, success) in
                        if success {
                            
                            self.currentSecondaryConditions = result!
                            
                            
                            //get tertiary weather conditions
                            openWeatherService.getCurrentWeather(city: userDefaults.string(forKey: GlobalConstants.TERTIARY_CITY_KEY)!, state:userDefaults.string(forKey: GlobalConstants.TERTIARY_STATE_KEY)!, latitude: userDefaults.string(forKey: GlobalConstants.TERTIARY_LAT_KEY)!, longitude: userDefaults.string(forKey: GlobalConstants.TERTIARY_LON_KEY)!) { (result, success) in
                                if success {
                                    
                                    self.currentTertiaryConditions = result!
                                    
                                    self.weatherCardsTable.reloadData()
                                    
                                }
                                else {
                                    //There was an error getting tertiary location weather conditions
                                }
                                
                            }
                            
                        }
                        else {
                            //There was an error getting secondary location weather conditions
                        }
                        
                    }
                    
                }
                else {
                    //There was an error getting primary location weather conditions
                }
                
            }
            
        }
        else {
            
            let alertController = UIAlertController(title: "Connection Error", message: "Please make sure you are connected to the internet and try again later.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
            
            
        }
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weatherLocations.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let screenRect = UIScreen.main.bounds
        let screenHeight = screenRect.size.height
        let navBarRect = self.navigationController?.navigationBar.bounds
        let navBarHeight = navBarRect?.size.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        
        
        return (screenHeight - navBarHeight! - statusBarHeight) / CGFloat(weatherLocations.count);
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GlobalConstants.WEATHER_CELL_IDENTIFIER, for: indexPath as IndexPath) as! WeatherCardTableViewCell
        
        // Configure the cell...
        cell.locationName.text = weatherLocations[indexPath.row]
        
        if indexPath.row == 0 {
            cell.contentView.backgroundColor = UIColor.init(red: 159.0/255.0,
                                                            green: 99.0/255.0,
                                                            blue: 46.0/255.0,
                                                            alpha: 0.7)
            
            cell.cellBackground.image = UIImage(named: "home-background")
            
            cell.currentTemperature.text = "\(self.currentPrimaryConditions.temperature_fahrenheit)°F"
            cell.weatherIcon.image = UIImage(named:"\(self.currentPrimaryConditions.mainIcon).png")
            
            let userDefaults = UserDefaults.standard
            
            if userDefaults.bool(forKey: GlobalConstants.USING_CURRENT_LOCATION){
                cell.currentLocationLabel.text = "current location"
            }
            else {
                cell.currentLocationLabel.text = ""
            }
            
        }
        else if indexPath.row == 1 {
            cell.contentView.backgroundColor = UIColor.init(red: 1.0/255.0,
                                                            green: 114.0/255.0,
                                                            blue: 107.0/255.0,
                                                            alpha: 0.7)
            
            cell.cellBackground.image = UIImage(named: "home-background2")
            
            cell.currentTemperature.text = "\(self.currentSecondaryConditions.temperature_fahrenheit)°F"
            cell.weatherIcon.image = UIImage(named:"\(self.currentSecondaryConditions.mainIcon).png")
            
            cell.currentLocationLabel.text = ""
            
        }
        else {
            cell.contentView.backgroundColor = UIColor.init(red: 88.0/255.0,
                                                            green: 90.0/255.0,
                                                            blue: 136.0/255.0,
                                                            alpha: 0.7)
            
            cell.cellBackground.image = UIImage(named: "home-background3")
            
            cell.currentTemperature.text = "\(self.currentTertiaryConditions.temperature_fahrenheit)°F"
            cell.weatherIcon.image = UIImage(named:"\(self.currentTertiaryConditions.mainIcon).png")
            
            cell.currentLocationLabel.text = ""
            
        }
        
        cell.cellBackground.clipsToBounds = true;
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: false) //deselect row so that color is the same when row collapses
        
        //if !self.expander, initialize self.expander
        if (self.expander == nil) {
            self.expander = self.storyboard!.instantiateViewController(withIdentifier: "Expander") as? ExpandedViewController
            self.expander!.delegate = self
        }
        
        //add as childviewcontroller
        self.addChildViewController(self.expander!)
        
        //set the initial frame of the expander to be the same as the selected row
        self.expander!.view.frame = tableView.rectForRow(at: indexPath as IndexPath)
        self.expander!.view.center = CGPoint(x:self.expander!.view.center.x, y:self.expander!.view.center.y - tableView.contentOffset.y); // adjusts for the offset of the cell when you select it
        
        //save the chosenFrame
        self.chosenCellFrame = self.expander!.view.frame;
        
        //customize the expanderview based on row
        if indexPath.row == 0 {
            self.expander!.currentWeatherConditions = currentPrimaryConditions
            self.expander!.cell.backgroundColor = UIColor.init(red: 159.0/255.0, green: 99.0/255.0, blue: 46.0/255.0, alpha: 0.7)
            self.expander!.locationBackgroundImage.image = UIImage(named: "home-background")
        }
        else if indexPath.row == 1 {
            self.expander!.currentWeatherConditions = currentSecondaryConditions
            self.expander!.cell.backgroundColor = UIColor.init(red: 1.0/255.0, green: 114.0/255.0, blue: 107.0/255.0, alpha: 0.7)
            self.expander!.locationBackgroundImage.image = UIImage(named: "home-background2")
        }
        else {
            self.expander!.currentWeatherConditions = currentTertiaryConditions
            self.expander!.cell.backgroundColor = UIColor.init(red: 88.0/255.0, green: 90.0/255.0, blue: 136.0/255.0, alpha: 0.7)
            self.expander!.locationBackgroundImage.image = UIImage(named: "home-background3")
        }
        self.expander!.bottomCell.backgroundColor = self.expander!.cell.backgroundColor
        let label = self.expander?.locationLabel
        label!.text = weatherLocations[indexPath.row];
        
        
        //make the cell fully transparent.. will animate it back to fully opaque
        self.expander!.view.alpha = 0
        
        //add the expander as a subview
        self.view.addSubview(self.expander!.view)
        
        //animate the view
        UIView.animate(withDuration: 0.55, delay: 0.0, options: [], animations: { () -> Void in
            
            self.expander!.view.frame = tableView.frame
            self.expander!.locationBackgroundImage.alpha = 0.8
            self.expander!.view.alpha = 1
            self.expander!.view.backgroundColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            
            
        }, completion: { (finished: Bool) -> Void in
            
            self.expander!.didMove(toParentViewController: self)
            
        })
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // 1
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit" , handler: { (action, indexPath) -> Void in
            
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "EditLocation") as? EditLocationViewController
            vc?.delegate = self
            
            if indexPath.row == 0 {
                self.editingPrimary = true
            }
            else if indexPath.row == 1 {
                self.editingSecondary = true
            }
            else {
                self.editingTertiary = true
            }
            
            let vc_nav = UINavigationController(rootViewController: vc!)
            self.navigationController!.present(vc_nav, animated: true, completion: nil)
            
        })
        
        
        return [editAction]
    }
    
    func expandedCellWillCollapse() {
        
        expander!.willMove(toParentViewController: nil)
        self.expander!.currentTemperatureLabel.text = ""
        self.expander!.locationLabel.text = ""
        
        //animate the view
        UIView.animate(withDuration: 0.55, delay: 0.0, options: [], animations: { () -> Void in
            
            self.expander!.view.frame = self.chosenCellFrame
            self.expander!.locationBackgroundImage.alpha = 0
            self.expander!.view.alpha = 0
            self.expander!.view.backgroundColor = UIColor.init(red: 0.0/255.0,
                                                               green: 0.0/255.0,
                                                               blue: 0.0/255.0,
                                                               alpha: 1.0)
            
            
        }, completion: { (finished: Bool) -> Void in
            
            self.expander!.view.removeFromSuperview()
            self.expander!.removeFromParentViewController()
        })
        
    }
    
    func updateViewWithNewWeatherData(data:WeatherCondition) {
        
        if self.editingPrimary {
            
            self.editingPrimary = false
            
            self.currentPrimaryConditions = data
            self.weatherLocations[0] = "\(data.cityName), \(data.stateAbbreiviation)"
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(data.cityName, forKey:GlobalConstants.PRIMARY_CITY_KEY)
            userDefaults.set(data.stateAbbreiviation, forKey:GlobalConstants.PRIMARY_STATE_KEY)
            userDefaults.set(false, forKey:GlobalConstants.USING_CURRENT_LOCATION)
            userDefaults.synchronize()
            
        }
        else if self.editingSecondary {
            
            self.editingSecondary = false
            
            self.currentSecondaryConditions = data
            self.weatherLocations[1] = "\(data.cityName), \(data.stateAbbreiviation)"
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(data.cityName, forKey:GlobalConstants.SECONDARY_CITY_KEY)
            userDefaults.set(data.stateAbbreiviation, forKey:GlobalConstants.SECONDARY_STATE_KEY)
            userDefaults.synchronize()
            
        }
        else {
            
            self.editingTertiary = false
            
            self.currentTertiaryConditions = data
            self.weatherLocations[2] = "\(data.cityName), \(data.stateAbbreiviation)"
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(data.cityName, forKey:GlobalConstants.TERTIARY_CITY_KEY)
            userDefaults.set(data.stateAbbreiviation, forKey:GlobalConstants.TERTIARY_STATE_KEY)
            userDefaults.synchronize()
            
        }
        
        self.weatherCardsTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

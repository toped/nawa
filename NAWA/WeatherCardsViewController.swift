//
//  WeatherCardsViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit
import CoreLocation


class WeatherCardsViewController: UIViewController, CLLocationManagerDelegate, ExpandedCellDelegate, EditLocationDelegate {
    
    var locationManager:CLLocationManager!
    
    var weatherLocations = [String]()
    var chosenCellFrame = CGRect()
    var expander = ExpandedViewController?()
    var currentPrimaryConditions = WeatherCondition?()
    var currentSecondaryConditions = WeatherCondition?()
    var currentTertiaryConditions = WeatherCondition?()
    var editingPrimary = false
    var editingSecondary = false
    var editingTertiary = false
    
    @IBOutlet weak var weatherCardsTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getWeather(self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        weatherLocations = ["\(self.currentPrimaryConditions!.cityName), \(self.currentPrimaryConditions!.stateAbbreiviation)",
                            "\(self.currentSecondaryConditions!.cityName), \(self.currentSecondaryConditions!.stateAbbreiviation)",
                            "\(self.currentTertiaryConditions!.cityName), \(self.currentTertiaryConditions!.stateAbbreiviation)"];
        
        self.edgesForExtendedLayout = UIRectEdge.None
        self.navigationItem.title = "NAWA"
        
        //re-configureUI Appearance
        self.configureUI()
        
        //Show the navigation bar
        self.navigationController?.navigationBarHidden = false
        
        //hide the back button
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain,
                                         target: navigationController,
                                         action: nil)
        
        navigationItem.leftBarButtonItem = backButton
        
        //set right bar button
        let changeLocationBtn = UIBarButtonItem(image: UIImage(named: "refresh-btn")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal),
                                                style: UIBarButtonItemStyle.Plain,
                                                target: self,
                                                action: #selector(self.refreshWeather))
        
        let currentLocationBtn = UIBarButtonItem(image: UIImage(named: "current-location-btn")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal),
                                                 style: UIBarButtonItemStyle.Plain,
                                                 target: self,
                                                 action: #selector(self.getWeatherAtLocation))
        
        navigationItem.rightBarButtonItems = [changeLocationBtn, currentLocationBtn]
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        self.getWeather(self)
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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
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
                                
                                let userDefaults = NSUserDefaults.standardUserDefaults()
                                userDefaults.setObject(placemark.locality, forKey:GlobalConstants.PRIMARY_CITY_KEY)
                                userDefaults.setObject(placemark.administrativeArea, forKey:GlobalConstants.PRIMARY_STATE_KEY)
                                
                                userDefaults.setBool(true, forKey: GlobalConstants.USING_CURRENT_LOCATION)
                                userDefaults.synchronize()
                                
                                self.weatherLocations[0] = "\(placemark.locality!), \(placemark.administrativeArea!)"
                                
                                self.getWeather(self)
                                
                            }
                        })
                    }
                    else {
                        
                        let alertController = UIAlertController(title: "Connection Error", message: "Please make sure you are connected to the internet and try again later.", preferredStyle: .Alert)
                        
                        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                            // ...
                        }
                        alertController.addAction(cancelAction)
                        
                        self.presentViewController(alertController, animated: true) {
                            // ...
                        }
                        
                        
                    }
                    
                }
            }
        }
    }
    
    func refreshWeather() {
        
        if (self.expander != nil) {
            self.expandedCellWillCollapse()
        }
        
        self.getWeather(self)
        
    }
    
    func getWeatherAtLocation() {
        
        let alertController = UIAlertController(title: "Update Primary Location", message: "Would you like to update primary weather using your current location?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            
            if (self.expander != nil) {
                self.expandedCellWillCollapse()
            }
            
            self.configureLocationServices()
            return
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
    }
    
    func configureUI() {
        
        //View controller-based status bar appearance added to Info.plist
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        
        
    }
    
    func getWeather(sender: AnyObject) {
        
        let openWeatherService = OpenWeather.init(apiKey:GlobalConstants.OPEN_WEATHER_API_KEY)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if GlobalConstants.hasConnectivity() {
            
            //get primary weather
            openWeatherService.getCurrentWeather(userDefaults.stringForKey(GlobalConstants.PRIMARY_CITY_KEY)!, state:userDefaults.stringForKey(GlobalConstants.PRIMARY_STATE_KEY)!) { (result, success) in
                if success {
                    
                    self.currentPrimaryConditions = result!
                    
                    //get secondary weather
                    openWeatherService.getCurrentWeather(userDefaults.stringForKey(GlobalConstants.SECONDARY_CITY_KEY)!, state:userDefaults.stringForKey(GlobalConstants.SECONDARY_STATE_KEY)!) { (result, success) in
                        if success {
                            
                            self.currentSecondaryConditions = result!
                            
                            
                            //get tertiary weather conditions
                            openWeatherService.getCurrentWeather(userDefaults.stringForKey(GlobalConstants.TERTIARY_CITY_KEY)!, state:userDefaults.stringForKey(GlobalConstants.TERTIARY_STATE_KEY)!) { (result, success) in
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
            
            let alertController = UIAlertController(title: "Connection Error", message: "Please make sure you are connected to the internet and try again later.", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            
            
        }
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weatherLocations.count
        
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let screenRect = UIScreen.mainScreen().bounds
        let screenHeight = screenRect.size.height
        let navBarRect = self.navigationController?.navigationBar.bounds
        let navBarHeight = navBarRect?.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        
        return (screenHeight - navBarHeight! - statusBarHeight) / CGFloat(weatherLocations.count);
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(GlobalConstants.WEATHER_CELL_IDENTIFIER, forIndexPath: indexPath) as! WeatherCardTableViewCell
        
        // Configure the cell...
        cell.locationName.text = weatherLocations[indexPath.row]
        
        if indexPath.row == 0 {
            cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 159.0/255.0, green: 99.0/255.0, blue: 46.0/255.0, alpha: 0.7)
            cell.cellBackground.image = UIImage(named: "home-background")
            
            cell.currentTemperature.text = "\(self.currentPrimaryConditions!.temperature_fahrenheit)°F"
            cell.weatherIcon.image = UIImage(named:"\(self.currentPrimaryConditions!.mainIcon).png")
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if userDefaults.boolForKey(GlobalConstants.USING_CURRENT_LOCATION){
                cell.currentLocationLabel.text = "current location"
            }
            else {
                cell.currentLocationLabel.text = ""
            }
            
        }
        else if indexPath.row == 1 {
            cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 1.0/255.0, green: 114.0/255.0, blue: 107.0/255.0, alpha: 0.7)
            cell.cellBackground.image = UIImage(named: "home-background2")
            
            cell.currentTemperature.text = "\(self.currentSecondaryConditions!.temperature_fahrenheit)°F"
            cell.weatherIcon.image = UIImage(named:"\(self.currentSecondaryConditions!.mainIcon).png")
            
            cell.currentLocationLabel.text = ""
            
        }
        else {
            cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 88.0/255.0, green: 90.0/255.0, blue: 136.0/255.0, alpha: 0.7)
            cell.cellBackground.image = UIImage(named: "home-background3")
            
            cell.currentTemperature.text = "\(self.currentTertiaryConditions!.temperature_fahrenheit)°F"
            cell.weatherIcon.image = UIImage(named:"\(self.currentTertiaryConditions!.mainIcon).png")
            
            cell.currentLocationLabel.text = ""
            
        }
        
        cell.cellBackground.clipsToBounds = true;
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false) //deselect row so that color is the same when row collapses
        
        //if !self.expander, initialize self.expander
        if (self.expander == nil) {
            self.expander = self.storyboard!.instantiateViewControllerWithIdentifier("Expander") as? ExpandedViewController
            self.expander!.delegate = self
        }
        
        //add as childviewcontroller
        self.addChildViewController(self.expander!)
        
        //set the initial frame of the expander to be the same as the selected row
        self.expander!.view.frame = tableView.rectForRowAtIndexPath(indexPath)
        self.expander!.view.center = CGPointMake(self.expander!.view.center.x, self.expander!.view.center.y - tableView.contentOffset.y); // adjusts for the offset of the cell when you select it
        
        //save the chosenFrame
        self.chosenCellFrame = self.expander!.view.frame;
        
        //customize the expanderview based on row
        if indexPath.row == 0 {
            self.expander!.currentWeatherConditions = currentPrimaryConditions
            self.expander!.cell.backgroundColor = UIColor.init(colorLiteralRed: 159.0/255.0, green: 99.0/255.0, blue: 46.0/255.0, alpha: 0.7)
            self.expander!.locationBackgroundImage.image = UIImage(named: "home-background")
        }
        else if indexPath.row == 1 {
            self.expander!.currentWeatherConditions = currentSecondaryConditions
            self.expander!.cell.backgroundColor = UIColor.init(colorLiteralRed: 1.0/255.0, green: 114.0/255.0, blue: 107.0/255.0, alpha: 0.7)
            self.expander!.locationBackgroundImage.image = UIImage(named: "home-background2")
        }
        else {
            self.expander!.currentWeatherConditions = currentTertiaryConditions
            self.expander!.cell.backgroundColor = UIColor.init(colorLiteralRed: 88.0/255.0, green: 90.0/255.0, blue: 136.0/255.0, alpha: 0.7)
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
        UIView.animateWithDuration(0.55, delay: 0.0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
            
            self.expander!.view.frame = tableView.frame
            self.expander!.locationBackgroundImage.alpha = 0.8
            self.expander!.view.alpha = 1
            self.expander!.view.backgroundColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            
            
            }, completion: { (finished: Bool) -> Void in
                
                self.expander!.didMoveToParentViewController(self)
                
        })
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        // 1
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("EditLocation") as? EditLocationViewController
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
            self.navigationController!.presentViewController(vc_nav, animated: true, completion: nil)
            
        })
        
        
        return [editAction]
    }
    
    func expandedCellWillCollapse() {
        
        expander!.willMoveToParentViewController(nil)
        self.expander!.currentTemperatureLabel.text = ""
        self.expander!.locationLabel.text = ""
        
        //animate the view
        UIView.animateWithDuration(0.55, delay: 0.0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
            
            self.expander!.view.frame = self.chosenCellFrame
            self.expander!.locationBackgroundImage.alpha = 0
            self.expander!.view.alpha = 0
            self.expander!.view.backgroundColor = UIColor.init(colorLiteralRed: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            
            
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
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data.cityName, forKey:GlobalConstants.PRIMARY_CITY_KEY)
            userDefaults.setObject(data.stateAbbreiviation, forKey:GlobalConstants.PRIMARY_STATE_KEY)
            userDefaults.setBool(false, forKey:GlobalConstants.USING_CURRENT_LOCATION)
            userDefaults.synchronize()
            
        }
        else if self.editingSecondary {
            
            self.editingSecondary = false
            
            self.currentSecondaryConditions = data
            self.weatherLocations[1] = "\(data.cityName), \(data.stateAbbreiviation)"
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data.cityName, forKey:GlobalConstants.SECONDARY_CITY_KEY)
            userDefaults.setObject(data.stateAbbreiviation, forKey:GlobalConstants.SECONDARY_STATE_KEY)
            userDefaults.synchronize()
            
        }
        else {
            
            self.editingTertiary = false
            
            self.currentTertiaryConditions = data
            self.weatherLocations[2] = "\(data.cityName), \(data.stateAbbreiviation)"
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data.cityName, forKey:GlobalConstants.TERTIARY_CITY_KEY)
            userDefaults.setObject(data.stateAbbreiviation, forKey:GlobalConstants.TERTIARY_STATE_KEY)
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
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

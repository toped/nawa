//
//  HomeViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation


class HomeViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, StateSelectionDelegate, CitySelectionDelegate {
    
    var locationManager:CLLocationManager!

    @IBOutlet weak var locationInputView: UIView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var getWeatherButton: UIButton!
    var states = [State]()
    var cities = [City]()
    
    var primaryCity: String?
    var primaryState: String?
    var secondaryCity: String?
    var secondaryState: String?
    var tertiaryCity: String?
    var tertiaryState: String?
    
    var primaryWeatherConditions = WeatherCondition?()
    var secondaryWeatherConditions = WeatherCondition?()
    var tertiaryWeatherConditions = WeatherCondition?()
    
    var currentLat: String?
    var currentLon: String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Hide the navigation bar
        self.navigationController?.navigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.secondaryCity = "Cupertino"
        self.secondaryState = "CA"
        self.tertiaryCity = "Seattle"
        self.tertiaryState = "WA"
        
        //check if primary city has been set
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if (userDefaults.objectForKey(GlobalConstants.PRIMARY_CITY_KEY) != nil) {
            
            self.primaryCity = userDefaults.stringForKey(GlobalConstants.PRIMARY_CITY_KEY)
            self.primaryState = userDefaults.stringForKey(GlobalConstants.PRIMARY_STATE_KEY)
            self.secondaryCity = userDefaults.stringForKey(GlobalConstants.SECONDARY_CITY_KEY)
            self.secondaryState = userDefaults.stringForKey(GlobalConstants.SECONDARY_STATE_KEY)
            self.tertiaryCity = userDefaults.stringForKey(GlobalConstants.TERTIARY_CITY_KEY)
            self.tertiaryState = userDefaults.stringForKey(GlobalConstants.TERTIARY_STATE_KEY)
            self.view.alpha = 0
            self.getWeather("viewDidLoad")
            
        }

        configureTapGestures()
        configureUI()

        //Populate the cities array
        self.populateStates()
    }
    
    func configureTapGestures() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
       
        self.view.addGestureRecognizer(tap)
        
    }
    
    func configureUI() {
        
        locationInputView.layer.cornerRadius = 5.0
        locationInputView.clipsToBounds = true
        
        getWeatherButton.layer.cornerRadius = 5.0
        getWeatherButton.clipsToBounds = true
        
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
 
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(self.locationManager.location!, completionHandler: { (placemarks, e) -> Void in
                        if e != nil {
                            print("Error:  \(e!.localizedDescription)")
                        } else {
                            let placemark = placemarks!.last! as CLPlacemark
                            
                            self.cityTextField.text = placemark.locality
                            self.stateTextField.text = placemark.administrativeArea
                            
                            self.getWeather(self)
                            
                        }
                    })
                    
                    
                    //self.getWeather("locationManager")
                }
            }
        }
    }

    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == self.stateTextField {
            self.selectState()
            
            return false
        }
        
        if textField == self.cityTextField {
            
            if self.stateTextField.hasText() {
                self.selectCity()
            }
            else {
                let alertController = UIAlertController(title: "Whoops", message: "You must select a state first.", preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                    // ...
                }
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true) {
                    // ...
                }

            }
            
            return false
        }
        
        return true
    }
    
    
    func selectState() {
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("States") as? StatesViewController
        vc?.delegate = self
        vc?.states = self.states
        let vc_nav = UINavigationController(rootViewController: vc!)
        self.navigationController!.presentViewController(vc_nav, animated: true, completion: nil)
        
    }
    
    func selectCity() {
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Cities") as? CitiesViewController
        vc?.delegate = self
        vc?.cities = self.cities
        let vc_nav = UINavigationController(rootViewController: vc!)
        self.navigationController!.presentViewController(vc_nav, animated: true, completion: nil)
        
    }
    
    func populateStates() {
        self.loadStatesPlistFromBundle()
        
        //Be sure to reinitialize array
        states = [State]()
        
        //Load States plist file
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let statesFilePath = directoryURL.URLByAppendingPathComponent("states.plist")
        
        //Create Dictionary from file (Note: swift APIs don't have all the functionality of the core NSClasses so we have to use NSDictionary)
        let statesDictionary = NSDictionary(contentsOfFile: statesFilePath.path!)
        
        //Create an instance of State for each record in plist file
        for stateRecord in statesDictionary! {
            print(stateRecord)
           //Create Dictionary from agent record
            let stateDictionary: NSDictionary = (statesDictionary?.objectForKey(stateRecord.key)) as! NSDictionary
            
            //Init the CountyAgent
            let state = State(
                name: stateDictionary.objectForKey("state") as! String,
                stateAbbriviation: stateDictionary.objectForKey("abbreviation") as! String
            )
            
            //Add county agent to countyAgents array
            states.append(state)
 
        }
       
        //Sort the array of states stateAbbriviation
        states.sortInPlace({ $0.stateAbbriviation < $1.stateAbbriviation })
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(states)
        userDefaults.setObject(encodedData, forKey:GlobalConstants.STATES_KEY)
        userDefaults.synchronize()
 
    }
    
    func loadStatesPlistFromBundle() {
        
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let destinationFileComponent = directoryURL.URLByAppendingPathComponent("states.plist")
        
        let bundle = NSBundle.mainBundle().pathForResource("states", ofType: "plist")! //Note: I'm force unwrappign because I know this file exists
        
        //If the file does not already exist int the documents folder copy the file in the bundle to the documents directory
        if !fileManager.fileExistsAtPath(destinationFileComponent.path!) {
            do {
                try fileManager.copyItemAtPath(bundle, toPath: destinationFileComponent.path!)
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
    

    @IBAction func getWeather(sender: AnyObject) {
        
        let openWeatherService = OpenWeather.init(apiKey:GlobalConstants.OPEN_WEATHER_API_KEY)
        
        var shouldAnimate = false
        
        if sender as! NSObject == self {
            self.primaryCity = cityTextField.text!
            self.primaryState = stateTextField.text!
            shouldAnimate = true
        }
        else if sender as! NSObject == self.getWeatherButton {
            configureLocationServices()
            return
        }
        else if sender as! String == "locationManager" {
            
        }
        
        //get primary weather
        openWeatherService.getCurrentWeather(self.primaryCity!, state:self.primaryState!) { (result, success) in
            if success {
                
                self.primaryWeatherConditions = result!
                
                //get secondary weather
                openWeatherService.getCurrentWeather(self.secondaryCity!, state:self.secondaryState!) { (result, success) in
                    if success {
                        
                        self.secondaryWeatherConditions = result!
                        
                        
                        //get tertiary weather conditions
                        openWeatherService.getCurrentWeather(self.tertiaryCity!, state:self.tertiaryState!) { (result, success) in
                            if success {
                                
                                self.tertiaryWeatherConditions = result!
                                
                                
                                UIView.setAnimationsEnabled(shouldAnimate)
                                self.performSegueWithIdentifier("getWeather", sender: nil)
                                
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
    
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
        
    }
    
    func updateViewWithState(state:String) {
        
        self.stateTextField.text = state
        
        let stateInfo = StateDataFecher.init()
        
        stateInfo.getCitiesForState(state, completion: { (result, success) in
            
            if success {
                
                self.cities = result!
                
            }
            else {
                
            }
            
        })
        
    
    }
    
    func updateViewWithCity(city:String) {
        
        self.cityTextField.text = city
        self.getWeather(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "getWeather" {
            
            let destinationView = segue.destinationViewController as! WeatherCardsViewController
            
            destinationView.currentPrimaryConditions = self.primaryWeatherConditions
            destinationView.currentSecondaryConditions = self.secondaryWeatherConditions
            destinationView.currentTertiaryConditions = self.tertiaryWeatherConditions
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(self.primaryWeatherConditions?.cityName, forKey:GlobalConstants.PRIMARY_CITY_KEY)
            userDefaults.setObject(self.primaryWeatherConditions?.stateAbbreiviation, forKey:GlobalConstants.PRIMARY_STATE_KEY)
            userDefaults.setObject(self.secondaryWeatherConditions?.cityName, forKey:GlobalConstants.SECONDARY_CITY_KEY)
            userDefaults.setObject(self.secondaryWeatherConditions?.stateAbbreiviation, forKey:GlobalConstants.SECONDARY_STATE_KEY)
            userDefaults.setObject(self.tertiaryWeatherConditions?.cityName, forKey:GlobalConstants.TERTIARY_CITY_KEY)
            userDefaults.setObject(self.tertiaryWeatherConditions?.stateAbbreiviation, forKey:GlobalConstants.TERTIARY_STATE_KEY)
            userDefaults.synchronize()

        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIView.setAnimationsEnabled(true)
    }
}


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
    var selectedCity = City()
    
    var primaryCity: String?
    var primaryState: String?
    var secondaryCity: String?
    var secondaryState: String?
    var tertiaryCity: String?
    var tertiaryState: String?
    
    var primaryLat: String?
    var primaryLon: String?
    var secondaryLat: String?
    var secondaryLon: String?
    var tertiaryLat: String?
    var tertiaryLon: String?
    
    var primaryWeatherConditions = WeatherCondition()
    var secondaryWeatherConditions = WeatherCondition()
    var tertiaryWeatherConditions = WeatherCondition()
    
    var currentLat: String?
    var currentLon: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Hide the navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.edgesForExtendedLayout = []
        
        self.secondaryCity = "Cupertino"
        self.secondaryState = "CA"
        self.tertiaryCity = "Seattle"
        self.tertiaryState = "WA"
        
        self.secondaryLat = "37.3230"
        self.secondaryLon = "-122.0322"
        self.tertiaryLat = "47.6062"
        self.tertiaryLon = "-122.3321"
        
        //check if primary city has been set
        let userDefaults = UserDefaults.standard
        if (userDefaults.object(forKey: GlobalConstants.PRIMARY_LAT_KEY) != nil) {
            
            self.primaryCity = userDefaults.string(forKey: GlobalConstants.PRIMARY_CITY_KEY)
            self.primaryState = userDefaults.string(forKey: GlobalConstants.PRIMARY_STATE_KEY)
            self.primaryLat = userDefaults.string(forKey: GlobalConstants.PRIMARY_LAT_KEY)
            self.primaryLon = userDefaults.string(forKey: GlobalConstants.PRIMARY_LON_KEY)
            
            self.secondaryCity = userDefaults.string(forKey: GlobalConstants.SECONDARY_CITY_KEY)
            self.secondaryState = userDefaults.string(forKey: GlobalConstants.SECONDARY_STATE_KEY)
        
            self.secondaryLat = userDefaults.string(forKey: GlobalConstants.SECONDARY_LAT_KEY)
            self.secondaryLon = userDefaults.string(forKey: GlobalConstants.SECONDARY_LON_KEY)
            
            self.tertiaryCity = userDefaults.string(forKey: GlobalConstants.TERTIARY_CITY_KEY)
            self.tertiaryState = userDefaults.string(forKey: GlobalConstants.TERTIARY_STATE_KEY)
            self.tertiaryLat = userDefaults.string(forKey: GlobalConstants.TERTIARY_LAT_KEY)
            self.tertiaryLon = userDefaults.string(forKey: GlobalConstants.TERTIARY_LON_KEY)
            
            self.view.alpha = 0
            self.getWeather(sender: "viewDidLoad" as AnyObject)
            
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
                                print(placemark)
                                self.cityTextField.text = placemark.locality
                                self.stateTextField.text = placemark.administrativeArea
                                self.primaryLat = "\(String(describing: placemark.location!.coordinate.latitude))"
                                self.primaryLon = "\(String(describing: placemark.location!.coordinate.longitude))"

                                let userDefaults = UserDefaults.standard
                                userDefaults.set(true, forKey: GlobalConstants.USING_CURRENT_LOCATION)
                                userDefaults.synchronize()
                                
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
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.stateTextField {
            self.selectState()
            
            return false
        }
        
        if textField == self.cityTextField {
            
            if self.stateTextField.hasText {
                self.selectCity()
            }
            else {
                let alertController = UIAlertController(title: "Whoops",
                                                        message: "You must select a state first.",
                                                        preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    // ...
                }
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true) {
                    // ...
                }
                
            }
            
            return false
        }
        
        return true
    }
    
    
    func selectState() {
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "States") as? StatesViewController
        vc?.delegate = self
        vc?.states = self.states
        let vc_nav = UINavigationController(rootViewController: vc!)
        self.navigationController!.present(vc_nav, animated: true, completion: nil)
        
    }
    
    func selectCity() {
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "Cities") as? CitiesViewController
        vc?.delegate = self
        vc?.cities = self.cities
        let vc_nav = UINavigationController(rootViewController: vc!)
        self.navigationController!.present(vc_nav, animated: true, completion: nil)
        
    }
    
    func populateStates() {
        self.loadStatesPlistFromBundle()
        
        //Be sure to reinitialize array
        states = [State]()
        
        //Load States plist file
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let statesFilePath = directoryURL.appendingPathComponent("states.plist")
        
        //Create Dictionary from file (Note: swift APIs don't have all the functionality of the core NSClasses so we have to use NSDictionary)
        let statesDictionary = NSDictionary(contentsOfFile: statesFilePath.path)
        
        //Create an instance of State for each record in plist file
        for stateRecord in statesDictionary! {
            //print(stateRecord)
            //Create Dictionary from agent record
            let stateDictionary: NSDictionary = (statesDictionary?.object(forKey: stateRecord.key)) as! NSDictionary
            
            //Init the CountyAgent
            let state = State(
                name: stateDictionary.object(forKey: "state") as! String,
                stateAbbriviation: stateDictionary.object(forKey: "abbreviation") as! String
            )
            
            //Add county agent to countyAgents array
            states.append(state)
            
        }
        
        //Sort the array of states stateAbbriviation
        states.sort(by: { $0.stateAbbriviation < $1.stateAbbriviation })
        
        let userDefaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: states)
        userDefaults.set(encodedData, forKey:GlobalConstants.STATES_KEY)
        userDefaults.synchronize()
        
    }
    
    func loadStatesPlistFromBundle() {
        
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationFileComponent = directoryURL.appendingPathComponent("states.plist")
        
        let bundle = Bundle.main.path(forResource: "states", ofType: "plist")! //Note: I'm force unwrappign because I know this file exists
        
        //If the file does not already exist int the documents folder copy the file in the bundle to the documents directory
        if !fileManager.fileExists(atPath: destinationFileComponent.path) {
            do {
                try fileManager.copyItem(atPath: bundle, toPath: destinationFileComponent.path)
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
        
        if GlobalConstants.hasConnectivity() {
            
            //get primary weather
            openWeatherService.getCurrentWeather(city: self.primaryCity!, state: self.primaryState!, latitude: self.primaryLat!, longitude: self.primaryLon!) { (result, success) in
                if success {
                    
                    self.primaryWeatherConditions = result!
                    
                    //get secondary weather
                    openWeatherService.getCurrentWeather(city: self.secondaryCity!, state: self.secondaryState!, latitude: self.secondaryLat!, longitude: self.secondaryLon!) { (result, success) in
                        if success {
                            
                            self.secondaryWeatherConditions = result!
                            
                            
                            //get tertiary weather conditions
                            openWeatherService.getCurrentWeather(city: self.tertiaryCity!, state: self.tertiaryState!, latitude: self.tertiaryLat!, longitude: self.tertiaryLon!) { (result, success) in
                                if success {
                                    
                                    self.tertiaryWeatherConditions = result!
                                    
                                    
                                    UIView.setAnimationsEnabled(shouldAnimate)
                                    self.performSegue(withIdentifier: "getWeather", sender: nil)
                                    
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
            
            let alertController = UIAlertController(title: "Connection Error",
                                                    message: "Please make sure you are connected to the internet and try again later.",
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
            
            
        }
        
    }
    
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
        
    }
    
    func updateViewWithState(state:String) {
        
        self.stateTextField.text = state
        
        let stateInfo = StateDataFecher.init()
        
        if GlobalConstants.hasConnectivity() {
            stateInfo.getCitiesForState(state: state, completion: { (result, success) in
                
                if success {
                    
                    self.cities = result!
                    
                }
                else {
                    
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
    
    func updateViewWithCity(city:City) {
        
        self.cityTextField.text = city.name
        self.selectedCity = city
        self.primaryLat = city.latitude
        self.primaryLon = city.longitude
        self.getWeather(sender: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getWeather" {
            
            let destinationView = segue.destination as! WeatherCardsViewController
            
            destinationView.currentPrimaryConditions = self.primaryWeatherConditions
            destinationView.currentSecondaryConditions = self.secondaryWeatherConditions
            destinationView.currentTertiaryConditions = self.tertiaryWeatherConditions
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(self.primaryWeatherConditions.cityName, forKey:GlobalConstants.PRIMARY_CITY_KEY)
            userDefaults.set(self.primaryWeatherConditions.stateAbbreiviation, forKey:GlobalConstants.PRIMARY_STATE_KEY)
            userDefaults.set(self.primaryWeatherConditions.latitude, forKey:GlobalConstants.PRIMARY_LAT_KEY)
            userDefaults.set(self.primaryWeatherConditions.longitude, forKey:GlobalConstants.PRIMARY_LON_KEY)

            userDefaults.set(self.secondaryWeatherConditions.cityName, forKey:GlobalConstants.SECONDARY_CITY_KEY)
            userDefaults.set(self.secondaryWeatherConditions.stateAbbreiviation, forKey:GlobalConstants.SECONDARY_STATE_KEY)
            userDefaults.set(self.secondaryWeatherConditions.latitude, forKey:GlobalConstants.SECONDARY_LAT_KEY)
            userDefaults.set(self.secondaryWeatherConditions.longitude, forKey:GlobalConstants.SECONDARY_LON_KEY)
            
            userDefaults.set(self.tertiaryWeatherConditions.cityName, forKey:GlobalConstants.TERTIARY_CITY_KEY)
            userDefaults.set(self.tertiaryWeatherConditions.stateAbbreiviation, forKey:GlobalConstants.TERTIARY_STATE_KEY)
            userDefaults.set(self.tertiaryWeatherConditions.latitude, forKey:GlobalConstants.TERTIARY_LAT_KEY)
            userDefaults.set(self.tertiaryWeatherConditions.longitude, forKey:GlobalConstants.TERTIARY_LON_KEY)
            
            userDefaults.synchronize()
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIView.setAnimationsEnabled(true)
    }
}


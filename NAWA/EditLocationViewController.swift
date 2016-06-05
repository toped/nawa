//
//  EditLocationViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 6/4/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit

protocol EditLocationDelegate: class {
    func updateViewWithNewWeatherData(data:WeatherCondition)
}

class EditLocationViewController: UIViewController, UITextFieldDelegate, StateSelectionDelegate, CitySelectionDelegate {
    
    weak var delegate:EditLocationDelegate?
    
    @IBOutlet weak var locationInputView: UIView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    var states = [State]()
    var cities = [City]()
    
    var weatherConditions = WeatherCondition?()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //set right bar button
        let dismissBtn = UIBarButtonItem(title:"Cancel",
                                         style: UIBarButtonItemStyle.Plain,
                                         target: self,
                                         action: #selector(self.dismissView))
        
        navigationItem.rightBarButtonItems = [dismissBtn]
        
        dismissBtn.tintColor = UIColor.lightGrayColor()
        
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
        
    }
    func dismissView() {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
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
        
        if (self.cities.count > 0) {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Cities") as? CitiesViewController
            vc?.delegate = self
            vc?.cities = self.cities
            let vc_nav = UINavigationController(rootViewController: vc!)
            self.navigationController!.presentViewController(vc_nav, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: "Whoops", message: "Cities are still loading. Please try again.", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }

        }
        
    }

    
    func getWeather(sender: AnyObject) {
        
        let openWeatherService = OpenWeather.init(apiKey:GlobalConstants.OPEN_WEATHER_API_KEY)
        
        
        //get primary weather
        openWeatherService.getCurrentWeather(self.cityTextField.text!, state:self.stateTextField.text!) { (result, success) in
            if success {
                
                self.weatherConditions = result!
                self.delegate?.updateViewWithNewWeatherData(self.weatherConditions!)
                
                self.dismissView()
            }
            else {
                //There was an error getting primary location weather conditions
            }
            
        }
        
    }
    
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
        
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
            //print(stateRecord)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

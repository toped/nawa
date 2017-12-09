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
    var selectedCity = City()
    
    var weatherConditions = WeatherCondition()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //set right bar button
        let dismissBtn = UIBarButtonItem(title:"Cancel",
                                         style: UIBarButtonItemStyle.plain,
                                         target: self,
                                         action: #selector(self.dismissView))
        
        navigationItem.rightBarButtonItems = [dismissBtn]
        
        dismissBtn.tintColor = UIColor.lightGray
        
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
    @objc func dismissView() {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
        
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
                let alertController = UIAlertController(title: "Whoops", message: "You must select a state first.", preferredStyle: .alert)
                
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
        
        if (self.cities.count > 0) {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "Cities") as? CitiesViewController
            vc?.delegate = self
            vc?.cities = self.cities
            let vc_nav = UINavigationController(rootViewController: vc!)
            self.navigationController!.present(vc_nav, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: "Whoops", message: "Cities are still loading. Please try again.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true) {
                // ...
            }

        }
        
    }

    
    func getWeather(sender: AnyObject) {
        
        let openWeatherService = OpenWeather.init(apiKey:GlobalConstants.OPEN_WEATHER_API_KEY)
        
        if GlobalConstants.hasConnectivity() {

        //get weather
            openWeatherService.getCurrentWeather(city: self.selectedCity.name, state: self.stateTextField.text!, latitude: self.selectedCity.latitude, longitude: self.selectedCity.longitude) { (result, success) in
            if success {
                
                self.weatherConditions = result!
                self.delegate?.updateViewWithNewWeatherData(data: self.weatherConditions)
                
                self.dismissView()
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
    
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
        
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
        self.getWeather(sender: self)
        
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

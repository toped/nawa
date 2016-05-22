//
//  HomeViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {

    @IBOutlet weak var locationInputView: UIView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var getWeatherButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Hide the navigation bar
        self.navigationController?.navigationBarHidden = true

        configureTapGestures()
        configureUI()
        
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
    
    @IBAction func getWeather(sender: AnyObject) {
        
        let openWeatherService = OpenWeather.init(apiKey:GlobalConstants.OPEN_WEATHER_API_KEY)
        
        openWeatherService.getCurrentWeather(cityTextField.text!, state:stateTextField.text!) {
            (result: Any, success: Bool) in
            print("got back: \(result)")
        }

    }
    
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


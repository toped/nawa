//
//  WeatherCardsViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit

class WeatherCardsViewController: UIViewController, ExpandedCellDelegate {
    
    var weatherLocations = [String]()
    var chosenCellFrame = CGRect()
    var expander = ExpandedViewController?()
    var currentPrimaryConditions = WeatherCondition?()
    var currentSecondaryConditions = WeatherCondition?()
    var currentTertiaryConditions = WeatherCondition?()

    @IBOutlet weak var weatherCardsTable: UITableView!
    
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
        let changeLocationBtn = UIBarButtonItem(image: UIImage(named: "new-location-btn")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal),
                                                style: UIBarButtonItemStyle.Plain,
                                                target: self,
                                                action: #selector(self.changeLocation))
        
        navigationItem.rightBarButtonItems = [changeLocationBtn]
        
        
    }
    
    func changeLocation() {
        
        
    }
    
    func configureUI() {
                
        //View controller-based status bar appearance added to Info.plist
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default

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

        }
        else if indexPath.row == 1 {
            cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 1.0/255.0, green: 114.0/255.0, blue: 107.0/255.0, alpha: 0.7)
            cell.cellBackground.image = UIImage(named: "home-background2")
            
            cell.currentTemperature.text = "\(self.currentSecondaryConditions!.temperature_fahrenheit)°F"
            cell.weatherIcon.image = UIImage(named:"\(self.currentSecondaryConditions!.mainIcon).png")

        }
        else {
            cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 88.0/255.0, green: 90.0/255.0, blue: 136.0/255.0, alpha: 0.7)
            cell.cellBackground.image = UIImage(named: "home-background3")
            
            cell.currentTemperature.text = "\(self.currentTertiaryConditions!.temperature_fahrenheit)°F"
            cell.weatherIcon.image = UIImage(named:"\(self.currentTertiaryConditions!.mainIcon).png")

        }
        
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
            self.expander!.cell.backgroundColor = UIColor.init(colorLiteralRed: 159.0/255.0, green: 99.0/255.0, blue: 46.0/255.0, alpha: 0.7)
            self.expander!.locationBackgroundImage.image = UIImage(named: "home-background")
            self.expander!.currentTemperatureLabel.text = "\(self.currentPrimaryConditions!.temperature_fahrenheit)°F"
            self.expander!.mainWeatherIcon.image = UIImage(named:"\(self.currentPrimaryConditions!.mainIcon).png")
        }
        else if indexPath.row == 1 {
            self.expander!.cell.backgroundColor = UIColor.init(colorLiteralRed: 1.0/255.0, green: 114.0/255.0, blue: 107.0/255.0, alpha: 0.7)
            self.expander!.locationBackgroundImage.image = UIImage(named: "home-background2")
            self.expander!.currentTemperatureLabel.text = "\(self.currentSecondaryConditions!.temperature_fahrenheit)°F"
            self.expander!.mainWeatherIcon.image = UIImage(named:"\(self.currentSecondaryConditions!.mainIcon).png")
        }
        else {
            self.expander!.cell.backgroundColor = UIColor.init(colorLiteralRed: 88.0/255.0, green: 90.0/255.0, blue: 136.0/255.0, alpha: 0.7)
            self.expander!.locationBackgroundImage.image = UIImage(named: "home-background3")
            self.expander!.currentTemperatureLabel.text = "\(self.currentTertiaryConditions!.temperature_fahrenheit)°F"
            self.expander!.mainWeatherIcon.image = UIImage(named:"\(self.currentTertiaryConditions!.mainIcon).png")
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

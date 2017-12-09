//
//  CitiesViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/25/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit

protocol CitySelectionDelegate: class {
    func updateViewWithCity(city:City)
}

class CitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate{

    weak var delegate:CitySelectionDelegate?
    var cities = [City]()
    var filteredCities = [City]()
    var searchController: UISearchController!
    
    var shouldShowSearchResults = false
    @IBOutlet weak var citiesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = []
        //Hide the navigation bar
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureSearchController()
        //re-configureUI Appearance
        self.configureUI()
        
        //set right bar button
        let dismissBtn = UIBarButtonItem(title:"Cancel",
                                         style: UIBarButtonItemStyle.plain,
                                         target: self,
                                         action: #selector(self.dismissView))
        
        navigationItem.rightBarButtonItems = [dismissBtn]
        
        dismissBtn.tintColor = UIColor.lightGray
        
    }
    
    func dismissKeyboard() {
        
        //self.searchController.active = false;
        self.searchController.searchBar.resignFirstResponder()
        
    }
    
    // needed a second dismiss function to avoid error: (-[UIBarButtonItem copyWithZone:]: unrecognized selector sent to instance)
    @objc func dismissView() {
        
        // Clear the Search bar text
        self.searchController.isActive = false;
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    func dismissViewWith(city: City?) {
        
        // Clear the Search bar text
        self.searchController.isActive = false;
        self.navigationController?.dismiss(animated: true, completion: {
            
            if city != nil {
                self.delegate?.updateViewWithCity(city: city!)
            }
            
        })
        
    }
    
    func configureUI() {
        
        //View controller-based status bar appearance added to Info.plist
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShowSearchResults {
            return filteredCities.count
        }
        else {
            return cities.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GlobalConstants.CITY_CELL_IDENTIFIER, for: indexPath)
        
        // Configure the cell...
        if shouldShowSearchResults {
            cell.textLabel?.text = "\(filteredCities[indexPath.row].name)"
        }
        else {
            cell.textLabel?.text = "\(cities[indexPath.row].name)"
            //cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.textLabel?.text == "" {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            return
        }
        
        var selectedCity = City()
        
        if shouldShowSearchResults {
            selectedCity = filteredCities[indexPath.row]
        }
        else {
            selectedCity = cities[indexPath.row]
        }
        
        
        self.dismissViewWith(city: selectedCity)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
    
    // MARK: - Search controller
    func configureSearchController() {
        //note:  When the nil value is passed as an argument, the search controller knows that the view controller that exists to is also going to handle and display the search results. In any other case the results view controller is a different one.
        
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search cities..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        self.edgesForExtendedLayout = []
        
        // Place the search bar view to the tableview headerview.
        view.addSubview(searchController.searchBar)
        
        //countyOfficeTable.tableHeaderView = searchController.searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        citiesTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        citiesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            citiesTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredCities = cities.filter({ (city) -> Bool in
            let cityText: NSString = city.name as NSString
            
            return (cityText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableview.
        citiesTableView.reloadData()
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

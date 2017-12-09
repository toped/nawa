//
//  StatesViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit

protocol StateSelectionDelegate: class {
    func updateViewWithState(state:String)
}

class StatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate{
    
    weak var delegate:StateSelectionDelegate?
    var states = [State]()
    var filteredStates = [State]()
    var searchController: UISearchController!

    var shouldShowSearchResults = false
    @IBOutlet weak var statesTableView: UITableView!
    
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
    
    func dismissViewWith(state: String?) {
        
        // Clear the Search bar text
        self.searchController.isActive = false;
        self.navigationController?.dismiss(animated: true, completion: {
        
            if state != nil {
                self.delegate?.updateViewWithState(state: state!)
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
            return filteredStates.count
        }
        else {
            return states.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GlobalConstants.STATE_CELL_IDENTIFIER, for: indexPath)
        
        // Configure the cell...
        if shouldShowSearchResults {
            cell.textLabel?.text = "\(filteredStates[indexPath.row].name) (\(filteredStates[indexPath.row].stateAbbriviation))"
        }
        else {
            cell.textLabel?.text = "\(states[indexPath.row].name) (\(states[indexPath.row].stateAbbriviation))"
            //cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath as IndexPath)?.textLabel?.text == "" {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            return
        }
        
        var selectedState = State()
        
        if shouldShowSearchResults {
            selectedState = filteredStates[indexPath.row]
        }
        else {
            selectedState = states[indexPath.row]
        }
        
        self.dismissViewWith(state: selectedState.stateAbbriviation)

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
        searchController.searchBar.placeholder = "Search states..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        self.edgesForExtendedLayout = []
        
        // Place the search bar view to the tableview headerview.
        view.addSubview(searchController.searchBar)
        
        //countyOfficeTable.tableHeaderView = searchController.searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        statesTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        statesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            statesTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredStates = states.filter({ (state) -> Bool in
            let stateText: NSString = state.name as NSString
            
            return (stateText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableview.
        statesTableView.reloadData()
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

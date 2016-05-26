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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = UIRectEdge.None
        //Hide the navigation bar
        self.navigationController?.navigationBarHidden = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
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
                                                style: UIBarButtonItemStyle.Plain,
                                                target: self,
                                                action: #selector(self.dismissView))
        
        navigationItem.rightBarButtonItems = [dismissBtn]
        
        dismissBtn.tintColor = UIColor.lightGrayColor()

    }
    
    func dismissKeyboard() {
        
        //self.searchController.active = false;
        self.searchController.searchBar.resignFirstResponder()
        
    }
    
    func dismissView() {
        
        // Clear the Search bar text
        self.searchController.active = false;
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func configureUI() {
        
        //View controller-based status bar appearance added to Info.plist
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShowSearchResults {
            return filteredStates.count
        }
        else {
            return states.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(GlobalConstants.STATE_CELL_IDENTIFIER, forIndexPath: indexPath)
        
        // Configure the cell...
        if shouldShowSearchResults {
            cell.textLabel?.text = "\(filteredStates[indexPath.row].name), \(filteredStates[indexPath.row].stateAbbriviation)"
        }
        else {
            cell.textLabel?.text = "\(states[indexPath.row].name), \(states[indexPath.row].stateAbbriviation)"
            //cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "" {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        var selectedState = State()
        
        if shouldShowSearchResults {
            selectedState = filteredStates[indexPath.row]
        }
        else {
            selectedState = states[indexPath.row]
        }
        
        self.delegate?.updateViewWithState(selectedState.stateAbbriviation)
        
        self.dismissView()

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
        self.edgesForExtendedLayout = UIRectEdge.None
        
        // Place the search bar view to the tableview headerview.
        view.addSubview(searchController.searchBar)
        
        //countyOfficeTable.tableHeaderView = searchController.searchBar
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        statesTableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        statesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            statesTableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredStates = states.filter({ (state) -> Bool in
            let stateText: NSString = state.name
            
            return (stateText.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

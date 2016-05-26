//
//  ExpandedViewController.swift
//  NAWA
//
//  Created by Tope Daramola on 5/21/16.
//  Copyright © 2016 Tope Daramola. All rights reserved.
//

import UIKit

protocol ExpandedCellDelegate: class {
    func expandedCellWillCollapse()
}

class ExpandedViewController: UIViewController {
    
    weak var delegate:ExpandedCellDelegate?
    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var locationBackgroundImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationBackgroundImage.clipsToBounds = true
    }

    @IBAction func collapseBackToTableView(sender: AnyObject) {
        
        delegate!.expandedCellWillCollapse()
    
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

//
//  HomeTableViewController.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/17/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import SwiftHTTP
import Mixpanel

class HomeTableViewController: UITableViewController {
    
    var mixpanel : Mixpanel!
    
    @IBOutlet weak var limitSwitch: UISwitch!
    @IBOutlet weak var aboutButton: UIBarButtonItem!
    
    var currentRecipe : Recipe?
    var ingredients : Results<Ingredient>!

    @IBOutlet weak var detailLabel : UILabel!
    @IBAction func saveSwitchChange(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(limitSwitch.on, forKey: "switchState")
        mixpanel.track("Switch Button Tapped")
    }
    
    //MARK: View openings
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!], forState: UIControlState.Normal)
        navigationItem.backBarButtonItem = backButton
        aboutButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!], forState: UIControlState.Normal)
        
        mixpanel = Mixpanel.sharedInstance()
        limitSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey("switchState")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Table Setup

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = TableViewCell()
        
        if indexPath.section == 0 {
            
            let y = PantryListViewController.getNumberOfIngredients(PantryListViewController())()
            if y == 1 {
                cell.textLabel?.text = "\(y) Item Checked"
            } else {
                cell.textLabel?.text = "\(y) Items Checked"
            }
            cell.detailTextLabel?.text = "View Pantry"
            cell.accessoryType = UITableViewCellAccessoryType(rawValue: 1)!
            
        } else if (indexPath.section == 1) {
            cell.textLabel?.text = "Limit Search Results"
            cell.accessoryView = limitSwitch
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
        } else {
            cell.textLabel?.text = "Search Recipes"
            var myColor = UIColor(red: 24.0/255.0, green: 108.0/255.0, blue: 254.0/255.0, alpha: 1.0)
            cell.textLabel?.textColor = myColor
            cell.accessoryType = UITableViewCellAccessoryType(rawValue: 1)!
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 {
            return nil
        } else {
            return indexPath
        }
    }
    
    //MARK: Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            self.performSegueWithIdentifier("ShowPantry", sender: self)
            mixpanel.track("Show", properties: ["Screen" : "Pantry"])
        } else if (indexPath.section == 1) {
            return
        } else if (indexPath.section == 2) {
            let realm = Realm()
            ingredients = realm.objects(Ingredient)
            let ingredientsToSearchWith = ingredients.filter("isChecked = true")
            if ingredientsToSearchWith.count == 0 {
                let alertController = UIAlertController(title: "No Ingredients Added", message:
                    "Please add at least one ingredient from the pantry", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                
                presentViewController(alertController, animated: true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("nothingLoaded", object: nil)
                mixpanel.track("Error", properties: ["Cause" : "No Ingredients Entered"])
                tableView.reloadData()
                return
            }
            let keywordHelper = KeywordHelper()
            let ingredientsAsAString = keywordHelper.improveKeywords(ingredientsToSearchWith)
            
            println(ingredientsAsAString)
            var numParam : Int!
            var request = HTTPTask()
            if limitSwitch.on {
                numParam = 200
                mixpanel.track("Search", properties: ["Switch":"Enabled"])
            } else {
                numParam = 15
                mixpanel.track("Search", properties: ["Switch":"Disabled"])
            }
            var params = ["ingredients": ingredientsAsAString, "number": "\(numParam)"]
            let searchHandler = SearchHandling()
            searchHandler.makeGETRequest(request, params: params, sender: self)
            
            self.performSegueWithIdentifier("SearchRecipes", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "About" {
            mixpanel.track("About Page Viewed")
        }
    }
}
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
    
    var currentRecipe : Recipe?
    var ingredients : Results<Ingredient>!
    
    var backgroundTaskIsDone : Bool = false

    @IBOutlet weak var detailLabel : UILabel!
    
    //MARK: View openings
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mixpanel = Mixpanel.sharedInstance()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        backgroundTaskIsDone = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Table Setup
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = TableViewCell()
        
        if indexPath.section == 0 {
            
            let y = PantryTableViewController.getNumberOfIngredients(PantryTableViewController())()
            if y == 1 {
                cell.textLabel?.text = "\(y) Item Checked"
            } else {
                cell.textLabel?.text = "\(y) Items Checked"
            }
            cell.detailTextLabel?.text = "View Pantry"
            cell.accessoryType = UITableViewCellAccessoryType(rawValue: 1)!
            
        } else if (indexPath.section == 1) {
            
            let x = IngredientsListViewController.getNumberOfIngredients(IngredientsListViewController())()
            if x == 1 {
                cell.textLabel?.text = "\(x) Item"
            } else {
                cell.textLabel?.text = "\(x) Items"
            }
            cell.detailTextLabel?.text = "View Full List"
            cell.accessoryType = UITableViewCellAccessoryType(rawValue: 1)!
            
            
        } else /*if indexPath.section == 2*/ {
            cell.textLabel?.text = "Search Recipes"
            var myColor = UIColor(red: 24.0/255.0, green: 108.0/255.0, blue: 254.0/255.0, alpha: 1.0)
            cell.textLabel?.textColor = myColor
            cell.accessoryType = UITableViewCellAccessoryType(rawValue: 1)!
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    //MARK: Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            self.performSegueWithIdentifier("ShowPantry", sender: self)
            mixpanel.track("Show", properties: ["Screen" : "Pantry"])
        } else if (indexPath.section == 1) {
            self.performSegueWithIdentifier("ShowIngredients", sender: self)
            mixpanel.track("Show", properties: ["Screen" : "Other Ingredients"])
        } else if (indexPath.section == 2) {
            mixpanel.track("Search")
            let realm = Realm()
            ingredients = realm.objects(Ingredient)
            var ingredientsAsAString = ""
            
            for (var i = 0; i < ingredients.count; i++) {
                ingredientsAsAString += ingredients[i].name
                if (i != ingredients.count - 1) {
                    ingredientsAsAString += ","
                }
            }
            var request = HTTPTask()
            var params = ["ingredients": ingredientsAsAString, "number": "50"]
            let searchHandler = SearchHandling()
            searchHandler.makeGETRequest(request, params: params, sender: self)
            
            self.performSegueWithIdentifier("SearchRecipes", sender: self)
        }
    }
}
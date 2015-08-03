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

class HomeTableViewController: UITableViewController {
    
    var alertControllerDisplayed : Bool?
    var recipes: [Recipe] = []
    var recipeEntries : [RecipeEntry] = []
    var currentEntry : RecipeEntry?
    var currentRecipe : Recipe?
    var ingredients : Results<Ingredient>!

    @IBOutlet weak var detailLabel : UILabel!
    
    //MARK: View openings
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        recipes = []
        alertControllerDisplayed = nil
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
        } else if (indexPath.section == 1) {
            self.performSegueWithIdentifier("ShowIngredients", sender: self)
            
        } else if (indexPath.section == 2) {
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
            
            while alertControllerDisplayed == nil {
                continue
            }
            if (self.alertControllerDisplayed! == false) {
                self.performSegueWithIdentifier("SearchRecipes", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SearchRecipes" {
            
            let destVC : RecipesListTableViewController = segue.destinationViewController as! RecipesListTableViewController
            
            destVC.recipes = self.recipes
            destVC.recipeEntries = self.recipeEntries
        }
    }
}
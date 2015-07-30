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
    
    var currentRecipe : Recipe?
    
    var ingredients : Results<Ingredient>!

    @IBOutlet weak var detailLabel : UILabel!
    
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
    
    //MARK: Table View Data
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("MealTypeCell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "IngredientNumberCell")
        }
        if (indexPath.section == 1) {
            var enabledSwitch = UISwitch(frame: CGRectZero) as UISwitch
            enabledSwitch.on = false
            cell!.accessoryView = enabledSwitch
            
            switch indexPath.row {
            case 0:
                cell!.textLabel?.text = "Breakfast"
            case 1:
                cell!.textLabel?.text = "Lunch"
            case 2:
                cell!.textLabel?.text = "Dinner"
            case 3:
                cell!.textLabel?.text = "Dessert"
            default:
                cell!.textLabel?.text = "FOOD"
            }
        } else if (indexPath.section == 0) {
            let x = IngredientsListViewController.getNumberOfIngredients(IngredientsListViewController())()
            if x == 1 {
                cell!.textLabel?.text = "\(x) Item"
            }
            else {
                cell!.textLabel?.text = "\(x) Items"
            }
            cell!.detailTextLabel?.text = "View Full List"
            cell!.accessoryType = UITableViewCellAccessoryType(rawValue: 1)!
        } else if (indexPath.section == 2) {
            cell!.textLabel?.text = "Search Recipes"
            var myColor = UIColor(red: 24.0/255.0, green: 108.0/255.0, blue: 254.0/255.0, alpha: 1.0)
            cell!.textLabel?.textColor = myColor
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (indexPath.section == 1) {
            return nil
        } else {
            return indexPath
        }
    }
    
    //MARK: Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
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
            var params = ["ingredients": ingredientsAsAString, "number": "5"]
            
            makeGETRequest(request, params: params)
            
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
        }
    }
    
    func makeGETRequest(request: HTTPTask, params: [String: String]) -> Void {
        
        request.requestSerializer.headers["X-Mashape-Key"] = "FJawMe8OpmmshpTp64RqlIjIntsjp1R6F72jsnQ66oS3ntZREx"
        request.requestSerializer.headers["Accept"] = "application/json"
        request.responseSerializer = JSONResponseSerializer()
        request.GET("https://webknox-recipes.p.mashape.com/recipes/findByIngredients", parameters: params) { (response: HTTPResponse) in
            
            if let json: AnyObject = response.responseObject {
                
                if response.responseObject!.count == 5 {
                    
                    self.alertControllerDisplayed = false
                    for (var i = 0; i < 5; i++) {
                        self.currentRecipe = Recipe()
                        self.currentRecipe!.title = json[i]["title"] as! String
                        let usedCount = json[i]["usedIngredientCount"] as! Int
                        let missedCount = json[i]["missedIngredientCount"] as! Int
                        
                        if missedCount == 0 {
                            self.currentRecipe!.recipeDescription = "Uses \(usedCount) of your ingredients, and you don't need any more for this recipe!"
                        } else if missedCount == 1 {
                            self.currentRecipe!.recipeDescription = "Uses \(usedCount) of your ingredients but requires \(missedCount) more ingredient"
                        } else {
                            self.currentRecipe!.recipeDescription = "Uses \(usedCount) of your ingredients but requires \(missedCount) more ingredients"
                        }
                        
                        self.currentRecipe!.imageURL = json[i]["image"] as! String
                        self.currentRecipe!.id = json[i]["id"] as! Int
                        
                        self.recipes.append(self.currentRecipe!)
                        
                    }
                } else {
                    println("Didn't get enough results")
                    self.alertControllerDisplayed = true
                    let alertController = UIAlertController(title: "Error", message:
                        "Could not find any results", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
                println(self.recipes.count)
                
            } else {
                println("Unexpected error with the JSON object")
            }
        }
        
        while recipes.count != 5 && self.alertControllerDisplayed == false {
            continue
        }
        
    }
    
}
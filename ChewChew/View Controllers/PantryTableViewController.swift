//
//  PantryTableViewController.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/1/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import RealmSwift
import Mixpanel

class PantryTableViewController: UITableViewController {
    
    var mixpanel : Mixpanel!
    
    var ingredients : Results<Ingredient>!
    var pantryIngredients : [Ingredient] = []
    var ingredientsInPantry : Results<Ingredient>!
    var ingredientsToCheck : Results<Ingredient>!
    var currentPantryIngredient : Ingredient?
    
    @IBOutlet weak var checkUncheckAllButton : UIBarButtonItem!
    @IBAction func checkOrUncheckAll(sender: UIBarButtonItem) {
        let realm = Realm()
        ingredientsInPantry = realm.objects(Ingredient).filter("category = 'pantry'")
        ingredients = realm.objects(Ingredient)
        if ingredientsInPantry.count >= 10 {
            realm.write() {
                realm.delete(self.ingredientsInPantry)
            }
            mixpanel.track("Deleted Ingredient", properties: ["Style" : "UncheckAll"])
            tableView.reloadData()
            self.viewDidLoad()
            sender.title = "Check All"
        } else {
            for potentialIngredient in pantryIngredients {
                var matchesExistingIngredient = false
                
                for existingIngredient in ingredients {
                    if potentialIngredient.name.caseInsensitiveCompare(existingIngredient.name) == NSComparisonResult(rawValue: 0) {
                        matchesExistingIngredient = true
                        break
                    }
                }
                if !matchesExistingIngredient {
                    potentialIngredient.addedDate = NSDate()
                    realm.write() {
                        realm.add(potentialIngredient)
                    }
                    mixpanel.track("Added Ingredient", properties: ["Style" : "CheckAll"])
                }
            }
            tableView.reloadData()
            self.viewDidLoad()
            sender.title = "Uncheck All"
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mixpanel = Mixpanel.sharedInstance()
        tableView.dataSource = self
        tableView.delegate = self
        let realm = Realm()
        ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
        setUpPantry()
        
        if realm.objects(Ingredient).filter("category = 'pantry'").count >= 10 {
            self.checkUncheckAllButton.title = "Uncheck All"
        } else {
            self.checkUncheckAllButton.title = "Check All"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PantryCell", forIndexPath: indexPath) as! PantryTableViewCell
        let row = indexPath.row
        let pIngredient = pantryIngredients[row]
        cell.ingredient = pIngredient
        
        let realm = Realm()
        var ingredientIsInTheList = false
        for ingredient in ingredients {
            if (cell.textLabel?.text)!.caseInsensitiveCompare(ingredient.name) == NSComparisonResult(rawValue: 0) {
                ingredientIsInTheList = true
                break
            }
        }
        if ingredientIsInTheList {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PantryTableViewCell
        let realm = Realm()
        currentPantryIngredient = Ingredient()
        currentPantryIngredient!.name = (cell.textLabel?.text)!
        
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            currentPantryIngredient!.addedDate = NSDate()
            currentPantryIngredient!.category = "pantry"
            realm.write() {
                realm.add(self.currentPantryIngredient!)
            }
            mixpanel.track("Added Ingredient", properties: ["Style" : "CheckOne"])
        } else {
            for ingredient in ingredients {
                if currentPantryIngredient!.name.caseInsensitiveCompare(ingredient.name) == NSComparisonResult(rawValue: 0) {
                    currentPantryIngredient = ingredient
                    break
                }
            }
            realm.write() {
                realm.delete(self.currentPantryIngredient!)
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            mixpanel.track("Deleted Ingredient", properties: ["Style" : "UncheckOne"])
        }
        ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
        if ingredients.filter("category = 'pantry'").count >= 10 {
            self.checkUncheckAllButton.title = "Uncheck All"
        } else {
            self.checkUncheckAllButton.title = "Check All"
        }
        tableView.reloadData()
    }
    
    func getNumberOfIngredients() -> Int {
        let realm = Realm()
        return realm.objects(Ingredient).filter("category = 'pantry'").count
    }
    
    func setUpPantry() {
        pantryIngredients = []
        for (var i = 0; i < 10; i++) {
            switch i {
            case 0:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Salt"
                pantryIngredients.append(currentPantryIngredient!)
            case 1:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Pepper"
                pantryIngredients.append(currentPantryIngredient!)
            case 2:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Milk"
                pantryIngredients.append(currentPantryIngredient!)
            case 3:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Butter"
                pantryIngredients.append(currentPantryIngredient!)
            case 4:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Flour"
                pantryIngredients.append(currentPantryIngredient!)
            case 5:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Sugar"
                pantryIngredients.append(currentPantryIngredient!)
            case 6:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Beef"
                pantryIngredients.append(currentPantryIngredient!)
            case 7:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Chicken"
                pantryIngredients.append(currentPantryIngredient!)
            case 8:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Eggs"
                pantryIngredients.append(currentPantryIngredient!)
            default:
                currentPantryIngredient = Ingredient()
                currentPantryIngredient!.category = "pantry"
                currentPantryIngredient!.name = "Cheese"
                pantryIngredients.append(currentPantryIngredient!)
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

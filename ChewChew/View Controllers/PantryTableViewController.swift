//
//  PantryTableViewController.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/1/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import RealmSwift

class PantryTableViewController: UITableViewController {
    
    var ingredients : Results<Ingredient>!
    var pantryIngredients : [Ingredient] = []
    var currentPantryIngredient : Ingredient?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        let realm = Realm()
        ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
        setUpPantry()
        //pantryIngredients = ingredients.filter("category = 'pantry'")

        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 10
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PantryCell", forIndexPath: indexPath) as! PantryTableViewCell
        let row = indexPath.row
        let pIngredient = pantryIngredients[row]
        cell.ingredient = pIngredient
        //let pantry = Pantry.sharedInstance
        //pantry.listOfIngredients = ""
        //setUpCell(cell, currentRow: row)
        
        let realm = Realm()
        
        for ingredient in ingredients {
            if (cell.textLabel?.text)!.caseInsensitiveCompare(ingredient.name) == NSComparisonResult(rawValue: 0) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PantryTableViewCell
        let realm = Realm()
        currentPantryIngredient = Ingredient()
        currentPantryIngredient!.name = (cell.textLabel?.text)!
        //let pantry = Pantry.sharedInstance
        
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            currentPantryIngredient!.addedDate = NSDate()
            currentPantryIngredient!.category = "pantry"
            realm.write() {
                realm.add(self.currentPantryIngredient!)
            }
            
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
        }
        ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
        tableView.reloadData()
        //println(pantry.listOfIngredients)
        
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

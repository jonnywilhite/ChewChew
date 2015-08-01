//
//  RecipesListTableViewController.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/27/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Foundation
import SwiftHTTP
import RealmSwift

class RecipesListTableViewController: UITableViewController {
    
    var recipes: [Recipe] = []
    var currentRecipe : Recipe?
    var ingredients : Results<Ingredient>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeTableViewCell
        
        let row = indexPath.row
        let recipe = recipes[row]
        
        cell.recipe = recipe
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var urlString : String = "https://spoonacular.com/recipe/"
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! RecipeTableViewCell
        
        var test = cell.recipe?.title
        if let x = test {
            test = test!.replaceAll(" ", with: "-")
            urlString += test!
        }
        
        urlString += "-"
        var stringTestTwo : String
        let testTwo = cell.recipe?.id
        if let y = testTwo {
            stringTestTwo = String(testTwo!)
            urlString += stringTestTwo
        }
        
        let url = NSURL(string: urlString)
        UIApplication.sharedApplication().openURL(url!)
        
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

extension String {
    func exclude(excludeIt: String) -> String {
        return "".join(componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: excludeIt)))
    }
    func replaceAll(find:String, with:String) -> String {
        return stringByReplacingOccurrencesOfString(find, withString: with, options: .LiteralSearch, range: nil)
    }
}

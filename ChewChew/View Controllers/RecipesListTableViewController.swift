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
import ConvenienceKit

class RecipesListTableViewController: UITableViewController {
    
    var recipes: [Recipe] = []
    var recipeEntries : [RecipeEntry] = []
    var currentRecipe : Recipe?
    var ingredients : Results<Ingredient>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        for recipe in self.recipes {
            let url = NSURL(string: recipe.imageURL)
            let data = NSData(contentsOfURL: url!)
        }
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
        return recipeEntries.count
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
}

extension String {
    func exclude(excludeIt: String) -> String {
        return "".join(componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: excludeIt)))
    }
    func replaceAll(find:String, with:String) -> String {
        return stringByReplacingOccurrencesOfString(find, withString: with, options: .LiteralSearch, range: nil)
    }
}

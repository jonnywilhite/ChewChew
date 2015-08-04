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
import Bond

class RecipesListTableViewController: UITableViewController, TimelineComponentTarget {
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    var timelineComponent : TimelineComponent<Recipe, RecipesListTableViewController>!
    
    var recipes : Dynamic<[Recipe]> = Dynamic([])
    var recipesToLoad : [Recipe] = []
    var recipeEntries : [RecipeEntry] = []
    var currentRecipe : Recipe?
    var ingredients : Results<Ingredient>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        timelineComponent = TimelineComponent(target: self)
        let shareData = ShareData.sharedInstance
        shareData.recipes ->> recipes
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timelineComponent.loadInitialIfRequired()
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
        return timelineComponent.content.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeTableViewCell
        
        let row = indexPath.row
        let recipe = timelineComponent.content[row]
        
        cell.recipe = recipe
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var urlString : String = "https://spoonacular.com/recipe/"
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! RecipeTableViewCell
        
        var test = cell.recipe?.title.value
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Recipe]?) -> Void) {
        // 1
        recipesToLoad = []
        for index in range {
            if index < recipes.value.count {
                recipesToLoad.append((recipes.value)[index])
            }
        }
        completionBlock(recipesToLoad)
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

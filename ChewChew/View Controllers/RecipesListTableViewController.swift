//
//  RecipesListTableViewController.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/27/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Foundation
import ConvenienceKit
import Bond
import Mixpanel

class RecipesListTableViewController: UITableViewController {
    
    var indicator : UIActivityIndicatorView!
    var urlToOpen : NSURL!
    var mixpanel : Mixpanel!
    
    var tableViewDataSourceBond: UITableViewDataSourceBond<RecipeTableViewCell>!
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    var recipes : DynamicArray<Recipe> = DynamicArray([])
    var recipesToLoad : [Recipe] = []
    var currentRecipe : Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Recipes", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!], forState: UIControlState.Normal)
        navigationItem.backBarButtonItem = backButton
        
        self.tableView.separatorColor = UIColor.whiteColor()
        mixpanel = Mixpanel.sharedInstance()
        indicator = UIActivityIndicatorView()
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.whiteColor()
        tableViewDataSourceBond = UITableViewDataSourceBond(tableView: self.tableView)
        tableView.delegate = self
        
        let shareData = ShareData.sharedInstance
        shareData.recipes ->> recipes
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList", name: "load", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopSpinning", name: "nothingLoaded", object: nil)
        recipes.map { [unowned self] (recipe: Recipe) -> RecipeTableViewCell in
            let cell = self.tableView.dequeueReusableCellWithIdentifier("RecipeCell") as! RecipeTableViewCell
            cell.recipe = recipe
            recipe.title ->> cell.titleLabel
            recipe.recipeDescription ->> cell.descriptionLabel
            recipe.image ->> cell.recipeImage
            if self.indicator.isAnimating() {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.tableView.separatorColor = UIColor.lightGrayColor()
            }
            return cell
            } ->> tableViewDataSourceBond
    }
    
    func loadList() {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.tableView.reloadData()
        }
    }
    
    func stopSpinning() {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //timelineComponent.loadInitialIfRequired()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mixpanel.track("Tapped On Recipe Entry")
        
        var urlString : String = "http://spoonacular.com/recipe/"
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! RecipeTableViewCell
        
        var test = cell.titleLabel.text
        if let x = test {
            test = test!.replaceAll(" ", with: "-")
            urlString += test!
        }
        urlString += "-"
        var stringTestTwo : String
        let testTwo = cell.recipe?.id.value
        if let y = testTwo {
            stringTestTwo = String(testTwo!)
            urlString += stringTestTwo
        }
        self.urlToOpen = NSURL(string: urlString)
        performSegueWithIdentifier("ShowRecipe", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowRecipe" {
            let destVC : RecipeDisplayViewController = segue.destinationViewController as! RecipeDisplayViewController
            destVC.urlToOpen = self.urlToOpen
        }
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 200)
        self.view.addSubview(indicator)
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

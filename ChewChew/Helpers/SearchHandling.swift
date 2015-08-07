//
//  SearchHandling.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import SwiftHTTP
import UIKit
import Mixpanel

struct SearchHandling {
    
    func makeGETRequest(request: HTTPTask, params: [String: String], sender: HomeTableViewController) -> Void {
        
        var limitResults : Bool!
        
        let shareData = ShareData.sharedInstance
        shareData.recipes.value = []
        if sender.limitSwitch.on {
            limitResults = true
        } else {
            limitResults = false
        }
        
        request.requestSerializer.headers["X-Mashape-Key"] = "FJawMe8OpmmshpTp64RqlIjIntsjp1R6F72jsnQ66oS3ntZREx"
        request.requestSerializer.headers["Accept"] = "application/json"
        request.responseSerializer = JSONResponseSerializer()
        request.GET("https://webknox-recipes.p.mashape.com/recipes/findByIngredients", parameters: params) { (response: HTTPResponse) in
            
            if let json: AnyObject = response.responseObject {
                
                if response.responseObject!.count > 0 {
                    
                    for (var i = 0; i < response.responseObject!.count; i++) {
                        sender.currentRecipe = Recipe()
                        
                        //Set the title of the recipe
                        sender.currentRecipe!.title.value = json[i]["title"] as! String
                        
                        //Set the description of the recipe
                        let usedCount = json[i]["usedIngredientCount"] as! Int
                        let missedCount = json[i]["missedIngredientCount"] as! Int
                        if limitResults! && missedCount > 3 {
                            sender.currentRecipe = nil
                            continue
                        }
                        if missedCount == 0 {
                            sender.currentRecipe!.recipeDescription.value = "Uses \(usedCount) of your ingredients, and you don't need any more for this recipe!"
                        } else if missedCount == 1 {
                            sender.currentRecipe!.recipeDescription.value = "Uses \(usedCount) of your ingredients but requires \(missedCount) more ingredient"
                        } else {
                            sender.currentRecipe!.recipeDescription.value = "Uses \(usedCount) of your ingredients but requires \(missedCount) more ingredients"
                        }
                        
                        //Set the missingCount of the Recipe
                        sender.currentRecipe!.missingCount.value = missedCount
                        
                        //Set the id of the recipe
                        sender.currentRecipe!.id.value = json[i]["id"] as! Int
                        
                        //Set the image of the recipe
                        sender.currentRecipe!.imageURL.value = json[i]["image"] as! String
                        if sender.currentRecipe!.imageURL.value.rangeOfString(".jpg") != nil {
                            
                            if let url = NSURL(string: sender.currentRecipe!.imageURL.value) {
                                if let data = NSData(contentsOfURL: url) {
                                    sender.currentRecipe!.image.value = UIImage(data: data)
                                }
                            }
                        } else {
                            if let url = NSURL(string: "http://i.imgur.com/5ELXQWS.png") {
                                if let data = NSData(contentsOfURL: url) {
                                    sender.currentRecipe!.image.value = UIImage(data: data)
                                }
                            }
                        }
                        
                        //Add the recipe to the list to display in RecipesListTable VC
                        (shareData.recipes.value).append(sender.currentRecipe!)
                        shareData.recipes.value.sort { $0.missingCount.value < $1.missingCount.value }
                        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                        if shareData.recipes.value.count == 20 {
                            break
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: "Error", message:
                        "No recipes found", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    
                    sender.presentViewController(alertController, animated: true, completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("nothingLoaded", object: nil)
                    sender.mixpanel.track("Error", properties: ["Cause" : "No Recipes Found"])
                }
                
                println((shareData.recipes.value).count)
                sender.backgroundTaskIsDone = true
                
            } else {
                println("Unexpected error with the JSON object")
                let alertController = UIAlertController(title: "Error loading recipes", message:
                    "Recipes could not be loaded at this time due to a network error", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                
                sender.presentViewController(alertController, animated: true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("nothingLoaded", object: nil)
                sender.mixpanel.track("Error", properties: ["Cause" : "Error with JSON"])
            }
        }
    }
}
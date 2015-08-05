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

struct SearchHandling {
    
    func makeGETRequest(request: HTTPTask, params: [String: String], sender: HomeTableViewController) -> Void {
        
        let shareData = ShareData.sharedInstance
        shareData.recipes.value = []
        
        request.requestSerializer.headers["X-Mashape-Key"] = "FJawMe8OpmmshpTp64RqlIjIntsjp1R6F72jsnQ66oS3ntZREx"
        request.requestSerializer.headers["Accept"] = "application/json"
        request.responseSerializer = JSONResponseSerializer()
        request.GET("https://webknox-recipes.p.mashape.com/recipes/findByIngredients", parameters: params) { (response: HTTPResponse) in
            
            if let json: AnyObject = response.responseObject {
                
                if response.responseObject!.count > 0 {
                    
                    sender.alertControllerDisplayed = false
                    for (var i = 0; i < response.responseObject!.count; i++) {
                        sender.currentRecipe = Recipe()
                        sender.currentEntry = RecipeEntry()
                        
                        sender.currentRecipe!.title.value = json[i]["title"] as! String
                        let usedCount = json[i]["usedIngredientCount"] as! Int
                        let missedCount = json[i]["missedIngredientCount"] as! Int
                        
                        if missedCount > 3 {
                            sender.currentRecipe = nil
                            sender.currentEntry = nil
                            continue
                        }
                        
                        if missedCount == 0 {
                            sender.currentRecipe!.recipeDescription.value = "Uses \(usedCount) of your ingredients, and you don't need any more for this recipe!"
                        } else if missedCount == 1 {
                            sender.currentRecipe!.recipeDescription.value = "Uses \(usedCount) of your ingredients but requires \(missedCount) more ingredient"
                        } else {
                            sender.currentRecipe!.recipeDescription.value = "Uses \(usedCount) of your ingredients but requires \(missedCount) more ingredients"
                        }
                        
                        sender.currentRecipe!.imageURL.value = json[i]["image"] as! String
                        sender.currentRecipe!.id = json[i]["id"] as! Int
                        
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
                        
                        sender.currentEntry!.recipe = sender.currentRecipe!
                        sender.recipes.append(sender.currentRecipe!)
                        sender.recipeEntries.append(sender.currentEntry!)
                        (shareData.recipes.value).append(sender.currentRecipe!)
                    }
                } else {
                    sender.alertControllerDisplayed = true
                    let alertController = UIAlertController(title: "Error", message:
                        "No recipes found", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    
                    sender.presentViewController(alertController, animated: true, completion: nil)
                }
                
                println(sender.recipes.count)
                sender.backgroundTaskIsDone = true
                NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                //sender.performSegueWithIdentifier("SearchRecipes", sender: sender)
                
            } else {
                println("Unexpected error with the JSON object")
            }
        }
    }
}
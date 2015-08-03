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
        
        request.requestSerializer.headers["X-Mashape-Key"] = "FJawMe8OpmmshpTp64RqlIjIntsjp1R6F72jsnQ66oS3ntZREx"
        request.requestSerializer.headers["Accept"] = "application/json"
        request.responseSerializer = JSONResponseSerializer()
        request.GET("https://webknox-recipes.p.mashape.com/recipes/findByIngredients", parameters: params) { (response: HTTPResponse) in
            
            if let json: AnyObject = response.responseObject {
                
                if response.responseObject!.count == 5 {
                    
                    sender.alertControllerDisplayed = false
                    for (var i = 0; i < 5; i++) {
                        sender.currentRecipe = Recipe()
                        sender.currentRecipe!.title = json[i]["title"] as! String
                        let usedCount = json[i]["usedIngredientCount"] as! Int
                        let missedCount = json[i]["missedIngredientCount"] as! Int
                        
                        if missedCount == 0 {
                            sender.currentRecipe!.recipeDescription = "Uses \(usedCount) of your ingredients, and you don't need any more for this recipe!"
                        } else if missedCount == 1 {
                            sender.currentRecipe!.recipeDescription = "Uses \(usedCount) of your ingredients but requires \(missedCount) more ingredient"
                        } else {
                            sender.currentRecipe!.recipeDescription = "Uses \(usedCount) of your ingredients but requires \(missedCount) more ingredients"
                        }
                        
                        sender.currentRecipe!.imageURL = json[i]["image"] as! String
                        sender.currentRecipe!.id = json[i]["id"] as! Int
                        
                        sender.recipes.append(sender.currentRecipe!)
                        
                    }
                } else {
                    sender.alertControllerDisplayed = true
                    let alertController = UIAlertController(title: "Error", message:
                        "Could not find any results", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    
                    sender.presentViewController(alertController, animated: true, completion: nil)
                }
                
                println(sender.recipes.count)
                
            } else {
                println("Unexpected error with the JSON object")
            }
        }
        
        while sender.recipes.count != 5 && sender.alertControllerDisplayed == false {
            continue
        }
        
    }
}
//
//  KeywordHelper.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/14/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import RealmSwift

struct KeywordHelper {
    
    func improveKeywords(ingredients: Results<Ingredient>) -> String {
        
        var ingredientsAsAString = ""
        for (var i = 0; i < ingredients.count; i++) {
            ingredientsAsAString += ingredients[i].name
            let name = ingredients[i].name
            if name.caseInsensitiveCompare("Chicken") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",chicken breasts,chicken bone,chicken breast,chicken legs,chicken thighs,chicken wings"
            } else if name.caseInsensitiveCompare("Beef") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",beef round roast,beef stew meat"
            } else if name.caseInsensitiveCompare("Mushrooms") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",cremini mushrooms"
            } else if name.caseInsensitiveCompare("Bell pepper") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",red bell pepper,green bell pepper,yellow bell pepper"
            } else if name.caseInsensitiveCompare("Salt") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",kosher salt"
            } else if name.caseInsensitiveCompare("Milk") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",skim milk"
            } else if name.caseInsensitiveCompare("Egg") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",egg yolk"
            } else if name.caseInsensitiveCompare("Sugar") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",natural cane sugar"
            } else if name.caseInsensitiveCompare("Carrot") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",baby carrots"
            } else if name.caseInsensitiveCompare("Pepper") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",ground black pepper,fresh ground pepper"
            } else if name.caseInsensitiveCompare("Corn") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",ear sweet corn,white corn"
            } else if name.caseInsensitiveCompare("Olive oil") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",extra virgin olive oil"
            } else if name.caseInsensitiveCompare("Onion") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",red onion"
            } else if name.caseInsensitiveCompare("Cucumber") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",lebanese cucumber,cucumbers"
            } else if name.caseInsensitiveCompare("Lemon") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",juice of lemon,lemon juice,lemon zest"
            } else if name.caseInsensitiveCompare("Cabbage") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",red cabbage"
            } else if name.caseInsensitiveCompare("Greek yogurt") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",greek yoghurt"
            } else if name.caseInsensitiveCompare("Bread") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",bread crumbs"
            } else if name.caseInsensitiveCompare("Lettuce") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",lettuce leaf,lettuce leaves"
            } else if name.caseInsensitiveCompare("Pork") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",pork loin"
            } else if name.caseInsensitiveCompare("Mayonnaise") == NSComparisonResult(rawValue: 0) {
                ingredientsAsAString += ",mayo"
            } 
            
            if (i != ingredients.count - 1) {
                ingredientsAsAString += ","
            }
        }
        
        return ingredientsAsAString
    }
}
//
//  Pantry.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/1/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Pantry {
    class var sharedInstance: Pantry {
        struct Static {
            static var instance: Pantry?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Pantry()
        }
        
        return Static.instance!
    }
    
    var listOfCurrentIngredients : String = ""
    var listOfAllIngredients : [String] = ["Salt", "Pepper", "Milk", "Butter", "Flour", "Sugar", "Beef", "Chicken", "Egg", "Bread", "Rice", "Beans", "Lettuce", "Tomato", "Pork", "Bacon", "Brown sugar", "Celery", "Salmon", "Corn", "Ground beef", "Bell pepper", "Onion", "Potato", "Avocado", "Baking powder", "Basil", "Broccoli", "Cabbage", "Canola oil", "Carrot", "Cheddar cheese", "Chocolate", "Cilantro", "Cream cheese", "Cucumber", "Garlic", "Ginger", "Greek yogurt", "Green beans", "Honey", "Jalapeno", "Lemon", "Lime", "Mushrooms", "Noodles", "Olive oil", "Parmesan cheese", "Parsley", "Pasta", "Sage", "Scallions", "Spinach", "Thyme", "Tofu", "Turkey", "Vanilla", "Walnuts", "Water", "Zucchini"]
    
    func setUpPantry() {
        let realm = Realm()
        
        for index in 0...59 {
            let currentIngredient = Ingredient()
            currentIngredient.name = listOfAllIngredients[index]
            currentIngredient.isChecked = false
            realm.write() {
                realm.add(currentIngredient)
            }
        }
    }
}
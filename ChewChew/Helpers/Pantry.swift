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
    var listOfAllIngredients : [String] = ["Salt", "Pepper", "Milk", "Butter", "Flour", "Sugar", "Beef", "Chicken", "Egg", "Cheese", "Bread", "Rice", "Beans", "Lettuce", "Tomato", "Pork", "Ham", "Bacon", "Brown Sugar", "Apple", "Banana", "Celery", "Salmon", "Crab", "Lobster", "Corn", "Ground Beef", "Bell Pepper", "Onion", "Potato"]
    
    func setUpPantry() {
        let realm = Realm()
        
        for index in 0...29 {
            let currentIngredient = Ingredient()
            currentIngredient.name = listOfAllIngredients[index]
            currentIngredient.isChecked = false
            realm.write() {
                realm.add(currentIngredient)
            }
        }
    }
    
}
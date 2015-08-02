//
//  Pantry.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/1/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import UIKit

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
    var listOfAllIngredients : [String] = ["salt", "pepper", "milk", "butter", "flour", "sugar", "beef", "chicken", "eggs", "cheese"]
    
}
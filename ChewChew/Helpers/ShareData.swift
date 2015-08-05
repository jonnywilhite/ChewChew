//
//  ShareData.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 7/31/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import RealmSwift
import Bond

class ShareData {
    class var sharedInstance: ShareData {
        struct Static {
            static var instance: ShareData?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ShareData()
        }
        
        return Static.instance!
    }
    
    var didAddNewIngredient : Bool!
    var selectedIngredient: Results<Ingredient>!
    var recipes: DynamicArray<Recipe> = DynamicArray([])
}
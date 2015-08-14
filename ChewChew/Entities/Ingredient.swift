//
//  Ingredient.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/17/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import RealmSwift

class Ingredient : Object {
    dynamic var name : String = "" {
        didSet {
            lowercaseName = name.lowercaseString
        }
    }
    dynamic var lowercaseName = ""
    dynamic var isChecked : Bool = false
}
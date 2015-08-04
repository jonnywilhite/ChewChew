//
//  Recipe.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/27/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import RealmSwift

class Recipe : NSObject {
    var title : String = ""
    var recipeDescription : String = ""
    var imageURL : String = ""
    var id : Int = 0
}
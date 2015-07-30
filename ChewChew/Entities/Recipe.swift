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
    dynamic var title : String = ""
    dynamic var recipeDescription : String = ""
    dynamic var imageURL : String = ""
    dynamic var id : Int = 0
}
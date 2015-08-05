//
//  Recipe.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/27/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import RealmSwift
import Bond
import ConvenienceKit

class Recipe : NSObject {
    var title : Dynamic<String> = Dynamic("")
    var recipeDescription : Dynamic<String> = Dynamic("")
    var imageURL : Dynamic<String> = Dynamic("")
    var image : Dynamic<UIImage?> = Dynamic(nil)
    var id : Int = 0
    
    static var imageCache : NSCacheSwift<String, UIImage>!
}
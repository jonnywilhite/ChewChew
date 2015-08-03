//
//  RecipeEntry.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/3/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Bond
import UIKit
import ConvenienceKit

class RecipeEntry : NSObject {
    
    var image : Dynamic<UIImage?> = Dynamic(nil)
    
    static var imageCache : NSCacheSwift<String, UIImage>!
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            
            //Create empty cache
            RecipeEntry.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
    
}
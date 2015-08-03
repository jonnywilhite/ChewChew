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
    
    var recipe : Recipe!
    var image : Dynamic<UIImage?> = Dynamic(nil)
    var photoDownloadTask : UIBackgroundTaskIdentifier?
    static var imageCache : NSCacheSwift<String, UIImage>!
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            
            //Create empty cache
            RecipeEntry.imageCache = NSCacheSwift<String, UIImage>()
        }
    }
    /*
    func downloadImage() {
        image.value = RecipeEntry.imageCache[self.recipe.imageURL]
        
        if (image.value == nil) {
            
            //Start download (in background this time!!)
            UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler() {
                
            }
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    
                    //Download complete, update image
                    self.image.value = image
                    
                    //Add image to cache... dictionaryName[key] = value
                    Post.imageCache[self.imageFile!.name] = image
                }
            }
        }
    }*/
    
}
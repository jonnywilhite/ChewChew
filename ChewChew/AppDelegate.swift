//
//  AppDelegate.swift
//  Template Project
//
//  Created by Benjamin Encz on 5/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import RealmSwift
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Mixpanel.sharedInstanceWithToken("c3bd3703fe1e9af157ee1b108951df74")
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
        
        
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 240.0/255.0, green: 161.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().translucent = true
        
        var titleBarAttributes : NSMutableDictionary = NSMutableDictionary(dictionary: UINavigationBar.appearance().titleTextAttributes!)
        titleBarAttributes.setValue(UIFont(name: "Avenir-Medium", size: 18), forKey: NSFontAttributeName)
        UINavigationBar.appearance().titleTextAttributes = titleBarAttributes as [NSObject : AnyObject]
        
        
        
        // Inside your application(application:didFinishLaunchingWithOptions:)
        
        // Notice setSchemaVersion is set to 1, this is always set manually. It must be
        // higher than the previous version (oldSchemaVersion) or an RLMException is thrown
        setSchemaVersion(6, Realm.defaultPath, { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if oldSchemaVersion < 6 {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        })
        // now that we have called `setSchemaVersion(_:_:_:)`, opening an outdated
        // Realm will automatically perform the migration and opening the Realm will succeed
        // i.e. Realm()
        // Override point for customization after application launch.
        
        let realm = Realm()
        if !NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            realm.write() {
                realm.deleteAll()
            }
            let pantry = Pantry.sharedInstance
            pantry.setUpPantry()
        }
        return true
    }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}


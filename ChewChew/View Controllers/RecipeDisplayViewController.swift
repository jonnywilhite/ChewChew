//
//  RecipeDisplayViewController.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/6/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Mixpanel

class RecipeDisplayViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView : UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var urlToOpen : NSURL!
    var mixpanel : Mixpanel!

    override func viewDidLoad() {
        super.viewDidLoad()
        mixpanel = Mixpanel.sharedInstance()
        
        webView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        if let urlRequest = urlToOpen {
            let request = NSURLRequest(URL: urlToOpen!)
            webView.loadRequest(request)
        }
        else {
            let alertController = UIAlertController(title: "Recipe Not Available", message:
                "Hyperlink to recipe is broken", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
            mixpanel.track("Error", properties: ["Cause" : "No Link to Recipe"])
            activityIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    @IBAction func doRefresh(AnyObject) {
        webView.reload()
    }
    
    @IBAction func goBack(AnyObject) {
        webView.goBack()
    }
    
    @IBAction func goForward(AnyObject) {
        webView.goForward()
    }
    
    @IBAction func stop(AnyObject) {
        webView.stopLoading()
    }

}

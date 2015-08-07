//
//  RecipeDisplayViewController.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/6/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class RecipeDisplayViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView : UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var urlToOpen : NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = NSURLRequest(URL: urlToOpen!)
        
        webView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        webView.loadRequest(request)
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

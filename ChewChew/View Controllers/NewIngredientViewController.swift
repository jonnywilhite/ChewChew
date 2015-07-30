//
//  NewIngredientViewController.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/22/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class NewIngredientViewController: UIViewController, UITextFieldDelegate {
    
    var currentIngredient : Ingredient?
    
    @IBOutlet weak var textField : UITextField!
    
    var textFieldText = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        
        self.textField.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        currentIngredient = Ingredient()
        currentIngredient!.name  = textField.text
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

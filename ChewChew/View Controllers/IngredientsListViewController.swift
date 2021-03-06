//
//  IngredientsListViewController.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/20/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation
import ConvenienceKit
import Mixpanel

class IngredientsListViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Variables/Outlets/Actions
    
    var mixpanel : Mixpanel!
    
    var tap: UITapGestureRecognizer!
    var selectedIngredient : Results<Ingredient>!
    var beginningText : String?
    var endingTextIsEmpty : Bool?
    var deleteButtonTappedWhileEditing : Bool? = false
    var isEditingTextField : Bool? = false
    var currentIngredient : Ingredient?
    var ingredientName : String?
    
    var ingredients : Results<Ingredient>! {
        didSet {
            tableView?.reloadData()
        }
    }
    var pantryIngredients : Results<Ingredient>!
    var userOnlyIngredients : Results<Ingredient>!
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var clearButton : UIButton!
    
    @IBOutlet weak var tableViewBottomSpace : NSLayoutConstraint!
    var keyboardNotificationHandler : KeyboardNotificationHandler?
    
    @IBAction func buttonTapped(sender: AnyObject) {
        let realm = Realm()
        self.tableView.dataSource = self
        
        if realm.objects(Ingredient).filter("category = 'user-specific'").count > 0 {
            let alertController = UIAlertController(title: "Clear all ingredients in this list?", message: "This can't be undone!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                
                
                realm.write() {
                    realm.delete(self.userOnlyIngredients)
                }
                self.mixpanel.track("Deleted Ingredient", properties: ["Style" : "ClearAllButton"])
                self.tableView.reloadData()
            }))
            
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    //MARK: Class fxns
    override func viewDidLoad() {
        mixpanel = Mixpanel.sharedInstance()
        buttonSetUp(clearButton)
        super.viewDidLoad()
        
        tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let realm = Realm()
        ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
        pantryIngredients = realm.objects(Ingredient).filter("category = 'pantry'")
        userOnlyIngredients = realm.objects(Ingredient).filter("category = 'user-specific'").sorted("addedDate", ascending: true)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        keyboardNotificationHandler = KeyboardNotificationHandler()
        
        keyboardNotificationHandler!.keyboardWillBeHiddenHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3) {
                self.tableViewBottomSpace.constant = 128
                self.view.layoutIfNeeded()
                self.view.removeGestureRecognizer(self.tap)
            }
        }
        
        keyboardNotificationHandler!.keyboardWillBeShownHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3) {
                self.tableViewBottomSpace.constant = height + 8
                self.view.layoutIfNeeded()
                self.view.addGestureRecognizer(self.tap)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNumberOfIngredients() -> Int {
        let realm = Realm()
        return realm.objects(Ingredient).filter("category = 'user-specific'").count
    }
    
    func buttonSetUp(button: UIButton) {
        if button == clearButton {
            button.backgroundColor = UIColor.redColor()
            button.layer.borderColor = UIColor.redColor().CGColor
        } else {
            button.backgroundColor = UIColor(red: 43.0/255.0, green: 190.0/255.0, blue: 0, alpha: 1.0)
            button.layer.borderColor = UIColor(red: 43.0/255.0, green: 190.0/255.0, blue: 0, alpha: 1.0).CGColor
        }
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
    }
    
    func dismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
//MARK: DataSource Ext.
extension IngredientsListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IngredientCell", forIndexPath: indexPath) as! IngredientTableViewCell
        cell.textField.delegate = self
        
        let row = indexPath.row
        if userOnlyIngredients.count > 0 {
            if row < userOnlyIngredients.count {
                let ingredient = userOnlyIngredients[row] as Ingredient
                cell.ingredient = ingredient
            } else if row == userOnlyIngredients.count {
                cell.textField.text = ""
            }
        } else {
            cell.textField.text = ""
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = Realm()
        
        return realm.objects(Ingredient).filter("category = 'user-specific'").count + 1
    }
}
//MARK: Delegate Ext.
extension IngredientsListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! IngredientTableViewCell
        
        cell.textField.becomeFirstResponder()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let realm = Realm()
        if indexPath.row < realm.objects(Ingredient).filter("category = 'user-specific'").count {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let ingredient = userOnlyIngredients[indexPath.row] as Object
            
            let realm = Realm()
            
            realm.write() {
                realm.delete(ingredient)
            }
            mixpanel.track("Deleted Ingredient", properties: ["Style" : "SwipeToDelete"])
            if isEditingTextField! {
                deleteButtonTappedWhileEditing = true
            } else {
                deleteButtonTappedWhileEditing = false
            }
            
            ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
            
            tableView.reloadData()
        }
    }
    
}

//MARK: TextField Delegate

extension IngredientsListViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
        isEditingTextField = true
        beginningText = textField.text
        let realm = Realm()
        let shareData = ShareData.sharedInstance
        
        if beginningText != "" {
            let predicate = NSPredicate(format: "name = %@", beginningText!)
            selectedIngredient = realm.objects(Ingredient).filter(predicate)
            shareData.selectedIngredient = selectedIngredient
            shareData.didAddNewIngredient = false
        } else {
            shareData.didAddNewIngredient = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.placeholder = "Add an Ingredient..."
        let realm = Realm()
        ingredients = realm.objects(Ingredient)
        userOnlyIngredients = ingredients.filter("category = 'user-specific'")
        if !deleteButtonTappedWhileEditing! {
            
            var endingText = textField.text
            
            for item in userOnlyIngredients {
                if endingText.caseInsensitiveCompare(item.name) == NSComparisonResult(rawValue: 0) {
                    textField.text = beginningText
                    endingText = textField.text
                    break
                }
            }
            
            if endingText == "" {
                endingTextIsEmpty = true
            } else {
                endingTextIsEmpty = false
            }
            
            let shareData = ShareData.sharedInstance
            let pantry = Pantry.sharedInstance
            
            if shareData.didAddNewIngredient! {
                currentIngredient = Ingredient()
                currentIngredient!.name = endingText
                
                for name in pantry.listOfAllIngredients {
                    if currentIngredient!.name.caseInsensitiveCompare(name) == NSComparisonResult(rawValue: 0) {
                        var isAlreadyInIngredients = false
                        for addedIngredient in ingredients {
                            if currentIngredient!.name.caseInsensitiveCompare(addedIngredient.name) == NSComparisonResult(rawValue: 0) {
                                isAlreadyInIngredients = true
                                break
                            }
                        }
                        if isAlreadyInIngredients {
                            let alertController = UIAlertController(title: "Item is already checked in the pantry!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                            endingTextIsEmpty = true
                            textField.text = beginningText
                            presentViewController(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: "Item has been checked in the pantry!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                            presentViewController(alertController, animated: true, completion: nil)
                            break
                        }
                    } else {
                    }
                }
                
                if !endingTextIsEmpty! {
                    realm.write() {
                        realm.add(self.currentIngredient!)
                    }
                    mixpanel.track("Added Ingredient", properties: ["Style" : "IngredientsList"])
                } else {
                    currentIngredient = nil
                }
            } else {
                
                currentIngredient = shareData.selectedIngredient[0] as Ingredient
                if endingTextIsEmpty! {
                    realm.write() {
                        realm.delete(self.currentIngredient!)
                    }
                    mixpanel.track("Deleted Ingredient", properties: ["Style" : "EmptyTextField"])
                } else {
                    
                    for name in pantry.listOfAllIngredients {
                        var isInPantry = false
                        if endingText.caseInsensitiveCompare(name) == NSComparisonResult(rawValue: 0) {
                            
                            isInPantry = true
                            realm.write() {
                            }
                            var isAlreadyInIngredients = false
                            for addedIngredient in ingredients {
                                
                                if endingText.caseInsensitiveCompare(addedIngredient.name) == NSComparisonResult(rawValue: 0) {
                                    isAlreadyInIngredients = true
                                    break
                                }
                            }
                            
                            if isAlreadyInIngredients {
                                
                                let alertController = UIAlertController(title: "Item is already checked in the pantry!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                                alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                                endingTextIsEmpty = true
                                textField.text = beginningText
                                presentViewController(alertController, animated: true, completion: nil)
                            } else {
                                
                                let alertController = UIAlertController(title: "Item has been checked in the pantry!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                                
                                alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                                presentViewController(alertController, animated: true, completion: nil)
                                break
                            }
                        }
                        realm.write() {
                        }
                    }
                    realm.write() {
                        self.currentIngredient!.name = textField.text
                    }
                }
            }
            ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
            tableView.reloadData()
        }
        //textFieldShouldReturn(textField)
        selectedIngredient = nil
        endingTextIsEmpty = nil
        isEditingTextField = false
        deleteButtonTappedWhileEditing = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
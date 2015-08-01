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

class IngredientsListViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Variables/Outlets/Actions
    
    var didAddNewItem : Bool?
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
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var clearButton : UIButton!
    
    @IBOutlet weak var tableViewBottomSpace : NSLayoutConstraint!
    var keyboardNotificationHandler : KeyboardNotificationHandler?
    
    @IBAction func buttonTapped(sender: AnyObject) {
        
        let realm = Realm()
        self.tableView.dataSource = self
        
        if realm.objects(Ingredient).count > 0 {
            let alertController = UIAlertController(title: "Clear All Ingredients?", message: "This can't be undone!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                
                
                realm.write() {
                    realm.deleteAll()
                }
                self.tableView.reloadData()
            }))
            
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    //MARK: Class fxns
    override func viewDidLoad() {
        clearButtonSetUp()
        super.viewDidLoad()
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let realm = Realm()
        ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        keyboardNotificationHandler = KeyboardNotificationHandler()
        
        keyboardNotificationHandler!.keyboardWillBeHiddenHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3) {
                self.tableViewBottomSpace.constant = 128
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardNotificationHandler!.keyboardWillBeShownHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3) {
                self.tableViewBottomSpace.constant = height + 8
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNumberOfIngredients() -> Int {
        let realm = Realm()
        ingredients = realm.objects(Ingredient).sorted("addedDate", ascending: true)
        let num = ingredients.count
        return num
    }
    
    func clearButtonSetUp() {
        clearButton.backgroundColor = UIColor.redColor()
        clearButton.layer.cornerRadius = 5
        clearButton.layer.borderWidth = 1
        clearButton.layer.borderColor = UIColor.redColor().CGColor
    }
    
    func DismissKeyboard(){
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
        if ingredients.count > 0 {
            if row < ingredients.count {
                let ingredient = ingredients[row] as Ingredient
                cell.ingredient = ingredient
            } else if row == ingredients.count {
                cell.textField.text = ""
            }
        } else {
            cell.textField.text = ""
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = Realm()
        
        return realm.objects(Ingredient).count + 1
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
        if indexPath.row < realm.objects(Ingredient).count {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let ingredient = ingredients[indexPath.row] as Object
            
            let realm = Realm()
            
            realm.write() {
                realm.delete(ingredient)
            }
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
        if !deleteButtonTappedWhileEditing! {
            
            var endingText = textField.text
            
            for item in realm.objects(Ingredient) {
                if endingText == item.name {
                    textField.text = beginningText
                    endingText = textField.text
                }
            }
            
            if endingText == "" {
                endingTextIsEmpty = true
            } else {
                endingTextIsEmpty = false
            }
            
            let shareData = ShareData.sharedInstance
            
            if shareData.didAddNewIngredient! {
                currentIngredient = Ingredient()
                currentIngredient!.name = endingText
                currentIngredient!.addedDate = NSDate()
                if !endingTextIsEmpty! {
                    realm.write() {
                        realm.add(self.currentIngredient!)
                    }
                } else {
                    currentIngredient = nil
                }
            } else {
                currentIngredient = shareData.selectedIngredient[0] as Ingredient
                if endingTextIsEmpty! {
                    realm.write() {
                        realm.delete(self.currentIngredient!)
                    }
                } else {
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
        didAddNewItem = nil
        endingTextIsEmpty = nil
        isEditingTextField = false
        deleteButtonTappedWhileEditing = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return false
    }
}
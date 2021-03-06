//
//  PantryListViewController.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/7/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import RealmSwift
import Mixpanel
import ConvenienceKit

class PantryListViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    var mixpanel : Mixpanel!
    
    var ingredients : Results<Ingredient>! {
        didSet {
            tableView?.reloadData()
        }
    }
    var checkedIngredients : Results<Ingredient>!
    var ingredientsToCheck : Results<Ingredient>!
    var currentPantryIngredient : Ingredient?
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var textField : UITextField!
    
    @IBOutlet weak var textFieldBottomSpace : NSLayoutConstraint!
    var keyboardNotificationHandler : KeyboardNotificationHandler?
    
    enum State {
        case DefaultMode
        case SearchMode
    }

    @IBOutlet weak var clearButton : UIBarButtonItem!
    @IBAction func clearButtonTapped(sender: UIBarButtonItem) {
        
        let realm = Realm()
        realm.write() {
            for ingredient in self.ingredients {
                ingredient.isChecked = false
            }
        }
        checkedIngredients = ingredients.filter("isChecked = true")
        sender.enabled = false
        self.view.endEditing(true)
        tableView.reloadData()
    }
    @IBOutlet weak var addButton : UIButton!
    @IBAction func addButtonTapped(sender: UIButton) {
        let realm = Realm()
        
        if self.textField.text != nil && self.textField.text != "" {
            for ingredient in ingredients {
                if textField.text.caseInsensitiveCompare(ingredient.name) == NSComparisonResult(rawValue: 0) {
                    println("not adding to realm")
                    self.textField.text = nil
                    self.view.endEditing(true)
                    return
                }
            }
            var newIngredient = Ingredient()
            newIngredient.name = self.textField.text
            newIngredient.isChecked = false
            realm.write() {
                realm.add(newIngredient)
            }
            mixpanel.track("Add Ingredient to Pantry")
            self.tableView.reloadData()
        }
        self.textField.text = nil
        self.view.endEditing(true)
    }
    
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                let realm = Realm()
                ingredients = realm.objects(Ingredient).sorted("lowercaseName", ascending: true)
                searchBar.resignFirstResponder()
                searchBar.text = ""
                searchBar.showsCancelButton = false
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                searchBar.setShowsCancelButton(true, animated: true)
                ingredients = searchIngredients(searchText).sorted("lowercaseName", ascending: true)
                UIView.animateWithDuration(0.3) {
                    self.textFieldBottomSpace.constant = 17
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = Realm()
        ingredients = realm.objects(Ingredient).sorted("lowercaseName", ascending: true)
        checkedIngredients = ingredients.filter("isChecked = true")
        
        clearButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!], forState: UIControlState.Normal)
        if checkedIngredients.count == 0 {
            clearButton.enabled = false
        }
        mixpanel = Mixpanel.sharedInstance()
        addButtonSetUp()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        textField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        keyboardNotificationHandler = KeyboardNotificationHandler()
        
        keyboardNotificationHandler!.keyboardWillBeHiddenHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3) {
                self.textFieldBottomSpace.constant = 8
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardNotificationHandler!.keyboardWillBeShownHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3) {
                if self.state == State.SearchMode {
                    return
                }
                self.textFieldBottomSpace.constant = height + 8
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
        return realm.objects(Ingredient).filter("isChecked = true").count
    }
    
    func searchIngredients(searchString: String) -> Results<Ingredient> {
        let realm = Realm()
        let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchString)
        return realm.objects(Ingredient).filter(searchPredicate).sorted("lowercaseName", ascending: true)
    }
    
    func addButtonSetUp() {
        
        addButton.backgroundColor = UIColor(red: 43.0/255.0, green: 190.0/255.0, blue: 0, alpha: 1.0)
        addButton.layer.borderColor = UIColor(red: 43.0/255.0, green: 170.0/255.0, blue: 0, alpha: 1.0).CGColor
        addButton.layer.cornerRadius = 5
        addButton.layer.borderWidth = 1
        addButton.hidden = true
    }
}

extension PantryListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PantryTableViewCell
        let realm = Realm()
        
        currentPantryIngredient = cell.ingredient
        
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            realm.write() {
                self.currentPantryIngredient!.isChecked = true
            }
            searchBar.text = nil
            ingredients = searchIngredients(searchBar.text).sorted("lowercaseName", ascending: true)
            mixpanel.track("Added Ingredient", properties: ["Style" : "CheckOne"])
        } else {
            realm.write() {
                self.currentPantryIngredient!.isChecked = false
            }
            searchBar.text = nil
            ingredients = searchIngredients(searchBar.text).sorted("lowercaseName", ascending: true)
            mixpanel.track("Deleted Ingredient", properties: ["Style" : "UncheckOne"])
        }
        
        checkedIngredients = ingredients.filter("isChecked = true")
        if checkedIngredients.count > 0 {
            self.clearButton.enabled = true
        } else {
            self.clearButton.enabled = false
        }
        if self.state == State.DefaultMode {
            self.view.endEditing(true)
        } else if self.state == State.SearchMode {
            self.searchBar.resignFirstResponder()
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let ingredient = ingredients[indexPath.row] as Object
            let realm = Realm()
            realm.write() {
                realm.delete(ingredient)
            }
            mixpanel.track("Deleted Ingredient", properties: ["Style" : "SwipeToDelete"])
            
            ingredients = realm.objects(Ingredient).sorted("lowercaseName", ascending: true)
            checkedIngredients = ingredients.filter("isChecked = true")
            tableView.reloadData()
        }
        if checkedIngredients.count == 0 {
            self.clearButton.enabled = false
        } else {
            self.clearButton.enabled = true
        }
        self.view.endEditing(true)
    }
}

extension PantryListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PantryCell", forIndexPath: indexPath) as! PantryTableViewCell
        let row = indexPath.row
        let ingredient = ingredients[row]
        cell.ingredient = ingredient
        
        if cell.ingredient!.isChecked {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
}

extension PantryListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ingredients = searchIngredients(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension PantryListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.addButtonTapped(self.addButton)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
        addButton.hidden = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.placeholder = "Add Ingredient..."
        addButton.hidden = true
    }
}
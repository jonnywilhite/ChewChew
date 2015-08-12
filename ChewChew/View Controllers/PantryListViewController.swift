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
                ingredients = realm.objects(Ingredient).sorted("name", ascending: true)
                searchBar.resignFirstResponder()
                searchBar.text = ""
                searchBar.showsCancelButton = false
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                searchBar.setShowsCancelButton(true, animated: true)
                ingredients = searchIngredients(searchText).sorted("name", ascending: true)
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
        ingredients = realm.objects(Ingredient).sorted("name", ascending: true)
        checkedIngredients = ingredients.filter("isChecked = true")
        
        clearButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!], forState: UIControlState.Normal)
        if checkedIngredients.count == 0 {
            clearButton.enabled = false
        }
        mixpanel = Mixpanel.sharedInstance()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        textField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        keyboardNotificationHandler = KeyboardNotificationHandler()
        
        keyboardNotificationHandler!.keyboardWillBeHiddenHandler = { (height: CGFloat) in
            UIView.animateWithDuration(0.3) {
                self.textFieldBottomSpace.constant = 17
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
        return realm.objects(Ingredient).filter(searchPredicate).sorted("name", ascending: true)
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
            ingredients = searchIngredients(searchBar.text).sorted("name", ascending: true)
            mixpanel.track("Added Ingredient", properties: ["Style" : "CheckOne"])
        } else {
            realm.write() {
                self.currentPantryIngredient!.isChecked = false
            }
            searchBar.text = nil
            ingredients = searchIngredients(searchBar.text).sorted("name", ascending: true)
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
        }
        tableView.reloadData()
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
}

extension PantryListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.placeholder = "Add Ingredient..."
    }
}
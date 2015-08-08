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

class PantryListViewController: UIViewController, UITableViewDelegate {
    
    var mixpanel : Mixpanel!
    
    var ingredients : Results<Ingredient>! {
        didSet {
            tableView?.reloadData()
        }
    }
    var checkedIngredients : Results<Ingredient>!
    var ingredientsToCheck : Results<Ingredient>!
    var currentPantryIngredient : Ingredient?
    var tap: UITapGestureRecognizer!
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    
    enum State {
        case DefaultMode
        case SearchMode
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
                self.view.removeGestureRecognizer(self.tap)
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                searchBar.setShowsCancelButton(true, animated: true)
                ingredients = searchIngredients(searchText)
                self.view.addGestureRecognizer(self.tap)
            }
        }
    }
    
    @IBOutlet weak var editButton : UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 17)!], forState: UIControlState.Normal)
        mixpanel = Mixpanel.sharedInstance()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        let realm = Realm()
        ingredients = realm.objects(Ingredient).sorted("name", ascending: true)
        checkedIngredients = ingredients.filter("isChecked = true")
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
    
    func dismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        searchBar.resignFirstResponder()
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
            mixpanel.track("Added Ingredient", properties: ["Style" : "CheckOne"])
        } else {
            realm.write() {
                self.currentPantryIngredient!.isChecked = false
            }
            mixpanel.track("Deleted Ingredient", properties: ["Style" : "UncheckOne"])
        }
        
        checkedIngredients = ingredients.filter("isChecked = true")
//        if checkedIngredients.count == ingredients.count {
//            self.checkUncheckAllButton.title = "Uncheck All"
//        } else {
//            self.checkUncheckAllButton.title = "Check All"
//        }
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
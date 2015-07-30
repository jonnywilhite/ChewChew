//
//  IngredientsListViewController.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/20/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientsListViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Variables
    
    var selectedIngredient : Ingredient?
    var ingredientName : String?
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var clearButton : UIButton!
    
    @IBAction func buttonTapped(sender: AnyObject) {
        tableView.dataSource = self
        
        let realm = Realm()
        realm.write() {
            realm.deleteAll()
        }
        tableView.reloadData()
    }
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier {
            let realm = Realm()
            switch identifier {
            case "Save":
                let source = segue.sourceViewController as! AddIngredientViewController //1
                
                realm.write() {
                    if source.currentIngredient!.name == "" {
                        realm.delete(self.selectedIngredient!)
                        source.currentIngredient = nil
                    } else {
                        self.selectedIngredient!.name = source.currentIngredient!.name
                    }
                }
                
            default:
                println("\(identifier)")
            }
            
            ingredients = realm.objects(Ingredient) //2
        }
    }
    
    @IBAction func unwindToSegue2(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier {
            let realm = Realm()
            switch identifier {
            case "Save":
                let source = segue.sourceViewController as! NewIngredientViewController //1
                
                if source.currentIngredient!.name != "" {
                    realm.write() {
                        realm.add(source.currentIngredient!)
                    }
                }
                
            default:
                println("\(identifier)")
            }
            
            ingredients = realm.objects(Ingredient) //2
        }
    }
    
    var currentIngredient: Ingredient?
    
    var ingredients : Results<Ingredient>! {
        didSet {
            tableView?.reloadData()
        }
    }
    //MARK: Class fxns
    override func viewDidLoad() {
        clearButtonSetUp()
        let realm = Realm()
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        ingredients = realm.objects(Ingredient)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNumberOfIngredients() -> Int {
        let realm = Realm()
        ingredients = realm.objects(Ingredient)
        let num = ingredients.count
        return num
    }
    
    func clearButtonSetUp() {
        clearButton.backgroundColor = UIColor.redColor()
        clearButton.layer.cornerRadius = 5
        clearButton.layer.borderWidth = 1
        clearButton.layer.borderColor = UIColor.redColor().CGColor
    }
    
    //MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Edit" {
            let destVC: AddIngredientViewController = segue.destinationViewController as! AddIngredientViewController
            destVC.textFieldText = ingredientName!
        }
    }
    
    
}
//MARK: DataSource Ext.
extension IngredientsListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IngredientCell", forIndexPath: indexPath) as! IngredientTableViewCell //1
        
        let row = indexPath.row
        let ingredient = ingredients[row] as Ingredient
        cell.ingredient = ingredient
        cell.textLabel?.text = ingredient.name
        cell.detailTextLabel?.text = "Edit"
        cell.accessoryType = UITableViewCellAccessoryType(rawValue: 1)!
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ingredient = ingredients {
            return Int(ingredients.count)
        } else {
            return 0
        }
    }
}
//MARK: Delegate Ext.
extension IngredientsListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIngredient = ingredients[indexPath.row]      //1
        ingredientName = selectedIngredient?.name
        self.performSegueWithIdentifier("Edit", sender: self)     //2
    }
    
    // 3
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // 4
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let ingredient = ingredients[indexPath.row] as Object
            
            let realm = Realm()
            
            realm.write() {
                realm.delete(ingredient)
            }
            
            ingredients = realm.objects(Ingredient)
        }
    }
    
}
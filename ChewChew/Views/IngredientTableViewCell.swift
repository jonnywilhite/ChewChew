//
//  IngredientTableViewCell.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/20/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import RealmSwift

class IngredientTableViewCell: UITableViewCell {
    var currentText: String?
    var selectedItem: Results<Ingredient>!
    
    @IBOutlet weak var textField : UITextField!
    
    var ingredient : Ingredient? {
        didSet {
            if let ingredient = ingredient, textField = textField {
                self.textField.text = ingredient.name
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  IngredientTableViewCell.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/20/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ingredientName : UILabel!
    
    var ingredient : Ingredient? {
        didSet {
            if let ingredient = ingredient, ingredientName = ingredientName {
                self.ingredientName.text = ingredient.name
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

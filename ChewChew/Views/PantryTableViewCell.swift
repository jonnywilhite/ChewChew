//
//  PantryTableViewCell.swift
//  ChewChew
//
//  Created by Jonathan Wilhite on 8/1/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class PantryTableViewCell: UITableViewCell {
    
    var isChecked : Bool!
    
    var ingredient : Ingredient? {
        didSet {
            if let ingredient = ingredient {
                self.textLabel?.text = ingredient.name
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

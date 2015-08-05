//
//  RecipeTableViewCell.swift
//  TemplateProject
//
//  Created by Jonathan Wilhite on 7/27/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    
    var id : Int!
    
    var recipe : Recipe? {
        didSet {
            if let recipe = recipe {
                self.id = recipe.id.value
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

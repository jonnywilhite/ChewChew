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
    
    var flag : Bool = false
    
    
    var recipe : Recipe? {
        didSet {
            if let recipe = recipe, titleLabel = titleLabel, descriptionLabel = descriptionLabel, recipeImage = recipeImage {
                self.titleLabel.text = recipe.title
                self.descriptionLabel.text = recipe.recipeDescription
                
                if recipe.imageURL.rangeOfString(".jpg") != nil {
                    
                    if let url = NSURL(string: recipe.imageURL) {
                        if let data = NSData(contentsOfURL: url) {
                            self.recipeImage.image = UIImage(data: data)
                        }
                    }
                } else {
                    flag = true
                    if let url = NSURL(string: "http://i.imgur.com/5ELXQWS.png") {
                        if let data = NSData(contentsOfURL: url) {
                            self.recipeImage.image = UIImage(data: data)
                        }
                    }
                }
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

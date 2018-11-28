//
//  CategoryCell.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/9/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var arroyImage: UIImageView!
    @IBOutlet weak var txtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func commonInit(_ aroyImage: String, categoryName: String) {
        arroyImage.image = UIImage(named: aroyImage)
        txtLabel.text = categoryName
    }
}

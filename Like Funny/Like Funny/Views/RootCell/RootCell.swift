//
//  RootCell.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/4/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit

class RootCell: UITableViewCell {

    @IBOutlet weak var rootImage: UIImageView!
    @IBOutlet weak var rootLabel: UILabel!
    @IBOutlet weak var arroyImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func commonInit(_ rootImg: String, categoryName: String, aroyImage: String) {
        rootImage.image = UIImage(named: rootImg)
        rootLabel.text = categoryName
        arroyImage.image = UIImage(named: aroyImage)
    }
}

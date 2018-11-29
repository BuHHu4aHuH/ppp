//
//  ArticleCell.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/17/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var displayedView: UIView!
    @IBOutlet weak var saved: UIButton!
    
    var sharingSwitchHandler: (() -> Void)?
    var saveToCoreDataSwitchHandler: (() -> Void)?
    var copyTextSwitchHandler: (() -> Void)?
    
    //TODO: Only for test
    var bool: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        displayedView.layer.masksToBounds = true
        displayedView.layer.cornerRadius = 8
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        articleLabel.text = nil
        saved.imageView?.image = UIImage(named: "WhiteStar95")
    }
    
    func commonInit(_ articleText: String) {
        articleLabel.text = articleText
    }
    
    //TODO: Use in cellForRow
//    func setupSaveButton(isSaved: Bool) {
//        if isSaved {
//            saved.imageView?.image = UIImage(named: "BlackStar95")
//        } else {
//            saved.imageView?.image = UIImage(named: "WhiteStar95")
//        }
//        //saved.imageView?.image = isSaved ? UIImage(named: "BlackStar95") : UIImage(named: "WhiteStar95")
//    }
    
    @IBAction func shareText(_ sender: Any) {
        print("Sharing DATA")
        
        sharingSwitchHandler?()
    }
    
    @IBAction func saveData(_ sender: Any) {
        print("SAVING/REMOVING DATA")
        //saved.setImage(UIImage(named: "BlackStar95"), for: .normal)
        saveToCoreDataSwitchHandler?()
    }
    @IBAction func copyText(_ sender: Any) {
        print("Copied Text")
        
        copyTextSwitchHandler?()
    }
    
}

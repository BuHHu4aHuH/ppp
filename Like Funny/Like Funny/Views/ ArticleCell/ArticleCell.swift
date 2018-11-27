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
    @IBOutlet weak var authurLabel: UILabel!
    @IBOutlet weak var displayedView: UIView!
    
    @IBOutlet weak var Saved: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        displayedView.layer.cornerRadius = 8
        displayedView.layer.masksToBounds = true
        
        Saved.imageView?.image = UIImage(named: "BlackStar95")
    }
    
    class var identifier: String {
        return String(describing: self)
    }
    
    func commonInit(_ articleText: String) {
        articleLabel.text = articleText
    }
    
    var sharingSwitchHandler: (() -> Void)?
    var saveToCoreDataSwitchHandler: (() -> Void)?
    var copyTextSwitchHandler: (() -> Void)?
    
    @IBAction func shareText(_ sender: Any) {
        print("Sharing DATA")
        
        sharingSwitchHandler?()
    }
    
    @IBAction func saveData(_ sender: Any) {
        print("SAVING/REMOVING DATA")
        Saved.setImage(UIImage(named: "BlackStar95"), for: .normal)
        saveToCoreDataSwitchHandler?()
    }
    @IBAction func copyText(_ sender: Any) {
        print("Copied Text")
        
        copyTextSwitchHandler?()
    }
    
}

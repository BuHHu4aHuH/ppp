//
//  Extensions.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/28/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
 
extension UIViewController {

    class var identifier: String {
        return String(describing: self)
    }
    
    static let tableViewCellHeight: CGFloat = 70
}

extension UITableViewCell {
    
    class var identifier: String {
        return String(describing: self)
    }
}

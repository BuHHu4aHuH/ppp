//
//  WorkWithDataSingleton.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/29/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit

class WorkWithDataSingleton {
    
    static var savedArticles = [Article]()
    
    struct categoriesModel {
        var name: String
        var key: String?
        
        init?(name: String?, key: String?) { guard let name = name else { return nil }
            self.name = name
            self.key = key
        }
    }
    
}

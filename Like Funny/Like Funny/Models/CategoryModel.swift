//
//  CategoryModel.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/4/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import Foundation

struct CategoryModel: Codable {
    var parent: String?
    var name: String?
    
    init?(json: [String: CategoryModel]) {
        parent = json["parent"] as? String
        name = json["name"] as? String
    }
}

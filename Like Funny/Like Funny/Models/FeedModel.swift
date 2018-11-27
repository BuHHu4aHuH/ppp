//
//  FeedModel.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/4/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import Foundation

struct Feed: Codable {
    var categories: [String : CategoryModel]?
    var items: [String : Elements]?
}

struct Elements: Codable {
    var elements: [String : data]?
    var categories: [Int: String]?
}

struct Categories: Codable {
    var category: String?
}

struct data: Codable {
    var data: zero?
}

struct zero: Codable {
    var zero: value?
    
    private enum CodingKeys: String, CodingKey {
        case zero = "0"
    }
}

struct value: Codable {
    var value: String?
}

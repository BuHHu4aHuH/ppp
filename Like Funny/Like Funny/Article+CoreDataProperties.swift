//
//  Article+CoreDataProperties.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/24/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var article: String?
    @NSManaged public var category: String?

}

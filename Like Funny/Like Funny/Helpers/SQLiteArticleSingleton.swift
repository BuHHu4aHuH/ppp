//
//  SQLiteArticleSingleton.swift
//  Like Funny
//
//  Created by Maksim Shershun on 12/14/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import SQLite

class SQLiteArticleSingleton {
    
    static var categoriesMass: [WorkWithDataSingleton.categoriesModel] = []
    
    static var categories = Feed()
    
    //SQLite Database
    
    static var categoriesDatabase: Connection!
    
    static let categoriesTable = Table("categories")
    static let idCategoriesTable = Expression<Int>("id")
    static let nameCategoriesTable = Expression<String>("name")
    static let parentCategoriesTable = Expression<String>("parent")
    static let keyCategoriesTable = Expression<String>("key")
    
    static var articleDatabase: Connection!
    
    static let articleTable = Table("article")
    static let idArticleTable = Expression<Int>("id")
    static let textArticleTable = Expression<String>("text")
    static let articleKey = Expression<String>("key")
    
    //SetupingTables
    
    static func setupTables() {
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("categories").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            SQLiteArticleSingleton.categoriesDatabase = database
        } catch {
            print(error)
        }
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("article").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            SQLiteArticleSingleton.articleDatabase = database
        } catch {
            print(error)
        }
    }
    
    //Create DB
    
    static func createTables() {
        print("CREATE TABLE")
        
        //CategoriesTable
        
        let createCategoriesTable = SQLiteArticleSingleton.categoriesTable.create { (table) in
            table.column(SQLiteArticleSingleton.idCategoriesTable, primaryKey: true)
            table.column(SQLiteArticleSingleton.parentCategoriesTable)
            table.column(SQLiteArticleSingleton.keyCategoriesTable)
            table.column(SQLiteArticleSingleton.nameCategoriesTable)
        }
        
        do {
            try SQLiteArticleSingleton.categoriesDatabase.run(createCategoriesTable)
            print("CREATED CATEGORIES TABLE")
        } catch {
            print(error)
        }
        
        //ArticleTable
        
        let createArticleTable = SQLiteArticleSingleton.articleTable.create { (table) in
            table.column(SQLiteArticleSingleton.idArticleTable, primaryKey: true)
            table.column(SQLiteArticleSingleton.textArticleTable)
            table.column(SQLiteArticleSingleton.articleKey)
        }
        
        do {
            try SQLiteArticleSingleton.articleDatabase.run(createArticleTable)
            print("CREATED ARTICLE TABLE")
        } catch {
            print(error)
        }
    }
    
    static func getData() {
        
        DataService.getData { (data) in
            do {
                let decoder = JSONDecoder()
                self.categories = try decoder.decode(Feed.self, from: data)
                
                //TODO: Use guard let
                if let dict = categories.categories {
                    
                    for (k, v) in dict {
                        
                        //TODO: Use guard let
                        if let parent = v.parent {
                            
                            if let name = v.name {
                                let insertCategory = self.categoriesTable.insert(self.nameCategoriesTable <- name, self.parentCategoriesTable <- parent, self.keyCategoriesTable <- k)
                                do {
                                    try self.categoriesDatabase.run(insertCategory)
                                    print("INSERTED CATEGORY")
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    }
                }
                
            } catch {
                print("ERROR:", error)
            }
        }
    }


    static func getDataArticles() {
        
        DataService.getData { (data) in
            do {
                let decoder = JSONDecoder()
                self.categories = try decoder.decode(Feed.self, from: data)
                
                if let dict2 = categories.items {
                    
                    var dictNumber: Int = 0
                    
                    for (k, v) in dict2 {
                        dictNumber += 1
                        
                        if let categories = v.categories {
                            
                            for category in categories {
                                
                                if let elements = v.elements {
                                    
                                    for element in elements {
                                        
                                        if let value = element.value.data?.zero?.value {
                                            
                                            var cleanValue = value.replacingOccurrences(of: "<[^>]+>", with: "\n", options: .regularExpression, range: nil)
                                            cleanValue = cleanValue.replacingOccurrences(of: "&#39;", with: "'", options: .regularExpression, range: nil)
                                            cleanValue = cleanValue.replacingOccurrences(of: "&nbsp;", with: "", options: .regularExpression, range: nil)
                                            cleanValue = cleanValue.replacingOccurrences(of: "&quot;", with: "\"" , options: .regularExpression, range: nil)
                                            cleanValue = cleanValue.replacingOccurrences(of: "&mdash;", with: "-", options: .regularExpression, range: nil)
                                            cleanValue = cleanValue.replacingOccurrences(of: "&ndash;", with: "-", options: .regularExpression, range: nil)
                                            cleanValue = cleanValue.replacingOccurrences(of: "&rsquo;", with: "’", options: .regularExpression, range: nil)
                                            
                                            let insertCategory = self.articleTable.insert(self.textArticleTable <- cleanValue, self.articleKey <- category.value)
                                            do {
                                                try self.articleDatabase.run(insertCategory)
                                                print("INSERTED CATEGORY = ", dictNumber)
                                            } catch {
                                                print("Error: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            } catch {
                print("ERROR:", error)
            }
        }
    }
                    
    static func readingData(categorySearching: String) -> [WorkWithDataSingleton.categoriesModel] {
        var categoriesModel: [WorkWithDataSingleton.categoriesModel] = []
        
        do {
            let categories = try SQLiteArticleSingleton.categoriesDatabase.prepare(SQLiteArticleSingleton.categoriesTable)
            for category in categories {
                if category[SQLiteArticleSingleton.parentCategoriesTable] == categorySearching {
                    let elem = WorkWithDataSingleton.categoriesModel(name: category[SQLiteArticleSingleton.nameCategoriesTable], key: category[SQLiteArticleSingleton.keyCategoriesTable])
                    
                    if let element = elem {
                        categoriesModel.append(element)
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        return categoriesModel
    }
}

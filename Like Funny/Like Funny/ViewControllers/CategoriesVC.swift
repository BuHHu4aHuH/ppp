//
//  CategoriesVC.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/5/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import SQLite

class CategoriesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var navigationTitle: String?
    let tableViewCellHeight: Int = 70
    
    var categories = Feed()
    
    var categoryKeyy: String?
   
    var categoriesMass = [WorkWithDataSingleton.categoriesModel]()
    
    var childMass = [WorkWithDataSingleton.categoriesModel]()
    
    //SQLite Database
    
    var categoriesDatabase: Connection!
    
    let categoriesTable = Table("categories")
    let idCategoriesTable = Expression<Int>("id")
    let nameCategoriesTable = Expression<String>("name")
    let parentCategoriesTable = Expression<String>("parent")
    let keyCategoriesTable = Expression<String>("key")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navigationTitle
        
        setupTables()
        createTables()
        
        categoriesMass = readingData(categorySearching: categoryKeyy!)
        
        self.categoriesMass = categoriesMass.sorted { $0.name > $1.name }

        setupTableView()
    }
    
    //SetupingTables
    
    func setupTables() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("categories").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.categoriesDatabase = database
        } catch {
            print(error)
        }
        
    }
    
    //Create DB
    
    func createTables() {
        print("CREATE TABLE")
        
        //CategoriesTable
        
        let createCategoriesTable = self.categoriesTable.create { (table) in
            table.column(self.idCategoriesTable, primaryKey: true)
            table.column(self.parentCategoriesTable)
            table.column(self.keyCategoriesTable)
            table.column(self.nameCategoriesTable)
        }
        
        do {
            try self.categoriesDatabase.run(createCategoriesTable)
            print("CREATED CATEGORIES TABLE")
        } catch {
            print(error)
        }
    }
    
    //ReadData from SQLite
    
    func readingData(categorySearching: String) -> [WorkWithDataSingleton.categoriesModel] {
        var categoriesModel: [WorkWithDataSingleton.categoriesModel] = []
        
        do {
            let categories = try self.categoriesDatabase.prepare(self.categoriesTable)
            for category in categories {
                if category[self.parentCategoriesTable] == categorySearching {
                    let elem = WorkWithDataSingleton.categoriesModel(name: category[self.nameCategoriesTable], key: category[self.keyCategoriesTable])
                    
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

extension CategoriesVC: UITableViewDelegate, UITableViewDataSource {
    
    //TableView
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibName = UINib(nibName: CategoryCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: CategoryCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesMass.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
        
        let data = categoriesMass[indexPath.row]
        
        cell.txtLabel?.text = data.name
        cell.arroyImage.image = UIImage(named: "arroy") //TODO: Rename
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        childMass = readingData(categorySearching: categoriesMass[indexPath.item].key!)
        
        if childMass.count != 0 {
            let desVC = storyboard?.instantiateViewController(withIdentifier: CategoriesChildVC.identifier) as! CategoriesChildVC
            
            desVC.navigationTitle = categoriesMass[indexPath.item].name
            desVC.categoryKeyy = categoriesMass[indexPath.item].key
            
            self.navigationController?.pushViewController(desVC, animated: true)
            
            childMass.removeAll()
        } else {
            let desVC = storyboard?.instantiateViewController(withIdentifier: ArticleVC.identifier) as! ArticleVC
            
            desVC.navigationTitle = categoriesMass[indexPath.item].name
            desVC.category = categoriesMass[indexPath.item].key
            
            self.navigationController?.pushViewController(desVC, animated: true)
            
            childMass.removeAll()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewCellHeight)
    }
}

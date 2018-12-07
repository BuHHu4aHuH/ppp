//
//  CategoriesChildVC.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/21/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import SQLite

class CategoriesChildVC: UIViewController  {
    
    @IBOutlet weak var tableView: UITableView!
    
    var navigationTitle: String?
    let tableViewCellHeight: Int = 70
    
    var categoriesMass = [WorkWithDataSingleton.categoriesModel]()
    var categoryKey: String?
    
    var database: Connection!
    
    let categoriesTable = Table("categoties")
    let id = Expression<Int>("id")
    let parentOfCategory = Expression<String>("categories")
    let keyOfCategory = Expression<String>("key")
    let name = Expression<String>("name")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navigationTitle
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("categories").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        createTable()
        
        categoriesMass = readingData(categorySearching: categoryKey!)
        
        self.categoriesMass = categoriesMass.sorted { $0.name > $1.name }
        
        setupTableView()
    }
    
    //Create DB
    
    func createTable() {
        print("CREATE TABLE")
        
        let createTable = self.categoriesTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.parentOfCategory)
            table.column(self.keyOfCategory)
            table.column(self.name)
            
        }
        
        do {
            try self.database.run(createTable)
            print("CREATED TABLE")
        } catch {
            print(error)
        }
    }
    
    //ReadData from SQLite
    
    func readingData(categorySearching: String) -> [WorkWithDataSingleton.categoriesModel] {
        var categoriesModel: [WorkWithDataSingleton.categoriesModel] = []
        
        do {
            let categories = try self.database.prepare(self.categoriesTable)
            for category in categories {
                if category[self.parentOfCategory] == categorySearching {
                    let elem = WorkWithDataSingleton.categoriesModel(name: category[self.name], key: category[self.keyOfCategory])
                    
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

extension CategoriesChildVC: UITableViewDelegate, UITableViewDataSource {
    
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
        cell.arroyImage.image = UIImage(named: "arroy")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let desVC = storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as! ArticleVC
        
        desVC.navigationTitle = categoriesMass[indexPath.item].name
        desVC.category = categoriesMass[indexPath.item].key
        
        self.navigationController?.pushViewController(desVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewCellHeight)
    }
}

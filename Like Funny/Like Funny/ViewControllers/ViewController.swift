//
//  ViewController.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/4/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import SQLite

class ViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let tableViewCellHeight: Int = 70
    var bannerView: GADBannerView!
    
    var categories = Feed()
    
    //SQLite Database
    
    var categoriesDatabase: Connection!
    
    let categoriesTable = Table("categories")
    let idCategoriesTable = Expression<Int>("id")
    let nameCategoriesTable = Expression<String>("name")
    let parentCategoriesTable = Expression<String>("parent")
    let keyCategoriesTable = Expression<String>("key")
    
    
    var articleDatabase: Connection!
    
    let articleTable = Table("article")
    let idArticleTable = Expression<Int>("id")
    let textArticleTable = Expression<String>("text")
    let articleKey = Expression<String>("key")
    let isSaved = Expression<Bool>("isSAved")
    
    var categoriesArticleDatabase: Connection!
    
    let categoriesArticleTable = Table("categoriesArticle")
    let categoryKey = Expression<String>("key")
    let articleId = Expression<Int>("articleId")
    
    
    var categoriesMass: [WorkWithDataSingleton.categoriesModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Favorite"), style: .plain, target: self, action: #selector(addTapped))
        
        
        setupTables()
        createTables()
        
        categoriesMass = readingData(categorySearching: "_root")
        
        if categoriesMass.count == 0 {
            getData()
            getDataArticles()
            categoriesMass = readingData(categorySearching: "_root")
        } else {
            
            //categoriesMass = readingData(categorySearching: "_root")
        }
        
        
        
        self.categoriesMass = categoriesMass.sorted { $0.name > $1.name }
        
        setupTableView()
        
        //setupBanner()
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
        
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("article").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.articleDatabase = database
        } catch {
            print(error)
        }
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("categoriesArticle").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.categoriesArticleDatabase = database
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
        
        //ArticleTable
        
        let createArticleTable = self.articleTable.create { (table) in
            table.column(self.idArticleTable, primaryKey: true)
            table.column(self.textArticleTable)
            table.column(self.articleKey)
            table.column(self.isSaved)
        }
        
        do {
            try self.articleDatabase.run(createArticleTable)
            print("CREATED ARTICLE TABLE")
        } catch {
            print(error)
        }
        
        //CategoriesArticleTable
        
        let createCategoriesArticleTable = self.categoriesArticleTable.create { (table) in
            table.column(self.categoryKey)
            table.column(self.articleId)
        }
        
        do {
            try self.categoriesArticleDatabase.run(createCategoriesArticleTable)
            print("CREATED CATEGORIESARTICLE TABLE")
        } catch {
            print(error)
        }
    }
    
    //Setup Banner
    
    func setupBanner() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        self.view.addSubview(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        
        let requestAD: GADRequest = GADRequest()
        requestAD.testDevices = [kGADSimulatorID]
        bannerView.load(requestAD)
    }
    
    //Open Saved
    
    @objc func addTapped() {
        let desVC = storyboard?.instantiateViewController(withIdentifier: SavedArticlesController.identifier) as! SavedArticlesController
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        do {
            let article = try PersistenceServce.context.fetch(fetchRequest)
            WorkWithDataSingleton.savedArticles = article
        } catch {
            print("Error in fetching CoreData")
        }
        
        self.navigationController?.pushViewController(desVC, animated: true)
    }
    
    //Get Data
    
    func getData() {
        DataService.getData { (data) in
            do {
                let decoder = JSONDecoder()
                self.categories = try decoder.decode(Feed.self, from: data)
                
                //TODO: Use guard let
                if let dict = categories.categories {
                    
                    //TODO: Sort func
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
    
    func getDataArticles() {
        DataService.getData { (data) in
            do {
                let decoder = JSONDecoder()
                self.categories = try decoder.decode(Feed.self, from: data)
                
                if let dict2 = categories.items {
                    for (k, v) in dict2 {
                        if let categories = v.categories {
                            for category in categories {
                                if let elements = v.elements {
                                    let amountOfElements = elements.count
                                    var j = 0
                                    for element in elements {
                                    //repeat {
                                        
                                        let heshKey = elements.keys
                                        let dataDict = elements[heshKey.first!]
                                        if let data = dataDict?.data {
                                            if let zero = data.zero {
                                                if let value = zero.value {
                                                    
                                                    //TODO: foreach and dictionary
                                                    var cleanValue = value.replacingOccurrences(of: "<[^>]+>", with: "\n", options: .regularExpression, range: nil)
                                                    cleanValue = cleanValue.replacingOccurrences(of: "&#39;", with: "'", options: .regularExpression, range: nil)
                                                    cleanValue = cleanValue.replacingOccurrences(of: "&nbsp;", with: "", options: .regularExpression, range: nil)
                                                    cleanValue = cleanValue.replacingOccurrences(of: "&quot;", with: "\"" , options: .regularExpression, range: nil)
                                                    cleanValue = cleanValue.replacingOccurrences(of: "&mdash;", with: "-", options: .regularExpression, range: nil)
                                                    cleanValue = cleanValue.replacingOccurrences(of: "&ndash;", with: "-", options: .regularExpression, range: nil)
                                                    cleanValue = cleanValue.replacingOccurrences(of: "&rsquo;", with: "’", options: .regularExpression, range: nil)
                                                    
                                                    let insertCategory = self.articleTable.insert(self.textArticleTable <- cleanValue, self.articleKey <- category.value, self.isSaved <- false)
                                                    do {
                                                        try self.articleDatabase.run(insertCategory)
                                                        print("INSERTED CATEGORY")
                                                    } catch {
                                                        print("ĘeeeeeeeeeeeeRRRRRRRRRRRRRROOOOOORRRRRR: \(error)")
                                                    }
                                                }
                                            }
                                        }
                                        //if (amountOfElements >= 2) {
                                         //   break
                                       // } else {
                                         //   j = j + 1;
                                       // }
                                    //} while (j < amountOfElements)
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

//MARK: - TableView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibName = UINib(nibName: RootCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: RootCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesMass.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewCellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RootCell.identifier, for: indexPath) as! RootCell
        
        let data = categoriesMass[indexPath.row]
        
        cell.rootLabel?.text = data.name
        cell.rootImage.image = UIImage(named: data.key!)
        cell.arroyImage.image = UIImage(named: "arroy") //TODO: Rename
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if categoriesMass[indexPath.item].key == "ukrajinski-privitannya" {
            let desVC = storyboard?.instantiateViewController(withIdentifier: ArticleVC.identifier) as! ArticleVC
            
            desVC.navigationTitle = categoriesMass[indexPath.item].name
            desVC.category = categoriesMass[indexPath.item].key
            
            self.navigationController?.pushViewController(desVC, animated: true)
        } else {
            let desVC = storyboard?.instantiateViewController(withIdentifier: CategoriesVC.identifier) as! CategoriesVC
            
            desVC.navigationTitle = categoriesMass[indexPath.item].name
            desVC.categoryKeyy = categoriesMass[indexPath.item].key
            
            self.navigationController?.pushViewController(desVC, animated: true)
        }
    }
}

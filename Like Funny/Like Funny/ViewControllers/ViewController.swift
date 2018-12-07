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
    
    var database: Connection!
    
    let categoriesTable = Table("categoties")
    let id = Expression<Int>("id")
    let parentOfCategory = Expression<String>("categories")
    let keyOfCategory = Expression<String>("key")
    let name = Expression<String>("name")
    
    var rootCategoriesName = [String]()
    var rootCategoriesKeys = [String]()
    
    var categoriesMass: [WorkWithDataSingleton.categoriesModel] = []
    var childCategoriesMass: [WorkWithDataSingleton.categoriesModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Favorite"), style: .plain, target: self, action: #selector(addTapped))
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("categories").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        createTable()
        
        getData()
        
        categoriesMass = readingData(categorySearching: "_root")
        
        self.categoriesMass = categoriesMass.sorted { $0.name > $1.name }
        
        setupTableView()
        setupBanner()
    }
    
    //Create DB
    
    func createTable() {
        print("CREATE TABLE")
        
        let createTable = self.categoriesTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.parentOfCategory)
            table.column(self.keyOfCategory)//, unique: true)
            table.column(self.name)
            
        }
        
        do {
            try self.database.run(createTable)
            print("CREATED TABLE")
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
                                let insertCategory = self.categoriesTable.insert(self.name <- name, self.parentOfCategory <- parent, self.keyOfCategory <- k)
                                do {
                                    try self.database.run(insertCategory)
                                    print("INSERTED CATEGORY")
                                } catch {
                                    print(error)
                                }
                                
                                if parent == "_root" {
                                    rootCategoriesKeys.append(k)
                                    rootCategoriesName.append(name)
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
            
            childCategoriesMass = readingData(categorySearching: categoriesMass[indexPath.item].key!)
            
            desVC.navigationTitle = categoriesMass[indexPath.item].name
            desVC.categoryKey = categoriesMass[indexPath.item].key
            
            self.navigationController?.pushViewController(desVC, animated: true)
        }
    }
}

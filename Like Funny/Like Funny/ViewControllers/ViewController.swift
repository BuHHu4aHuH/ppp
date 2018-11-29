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

class ViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var bannerView: GADBannerView!
    
    let tableViewCellHeight: Int = 70
    
    var categories = Feed()
    
    var category: String?
    
    var childMass: [WorkWithDataSingleton.categoriesModel] = []
    var categoriesMass: [WorkWithDataSingleton.categoriesModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "BlackStar95"), style: .plain, target: self, action: #selector(addTapped))
        
        categoriesMass =  getData(category: "_root")
        
        self.categoriesMass = categoriesMass.sorted { $0.name > $1.name }
        
        setupTableView()
        setupBanner()
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
    
    func getData(category: String) -> [WorkWithDataSingleton.categoriesModel] {
        var categoriesMass: [WorkWithDataSingleton.categoriesModel] = []
        
        DataService.getData { (data) in
            do {
                let decoder = JSONDecoder()
                self.categories = try decoder.decode(Feed.self, from: data)
                
                //TODO: Use guard let
                if let dict = categories.categories {
                    
                    //TODO: Sort func
                    for (k, v) in dict {
                        
                        //TODO: Use guard let
                        if let parent = v.parent, parent == category {
                            
                            if let name = v.name {
                                let elem = WorkWithDataSingleton.categoriesModel(name: name, key: k)
                                
                                if let element = elem {
                                    categoriesMass.append(element)
                                }
                            }
                        }
                    }
                }
                
            } catch {
                print("ERROR:", error)
            }
        }
        
        return categoriesMass
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
        searchingCategories(categoryKey: categoriesMass[indexPath.item].key!, category: categoriesMass[indexPath.item].name)
    }
    
    //Searching Child Categories
    
    func searchingCategories(categoryKey: String, category: String) {
        
        childMass = getData(category: categoryKey)
        self.childMass = childMass.sorted { $0.name > $1.name }
        if childMass.count != 0 {
            
            let desVC = storyboard?.instantiateViewController(withIdentifier: CategoriesVC.identifier) as! CategoriesVC
            
            desVC.navigationTitle = category
            
            let names = childMass.map { $0.name }
            let keys = childMass.map { $0.key }
            
            desVC.categoriesMass = names
            desVC.keyMass = keys as! [String]
            
            self.navigationController?.pushViewController(desVC, animated: true)
            
            childMass.removeAll()
        } else {
            let desVC = storyboard?.instantiateViewController(withIdentifier: ArticleVC.identifier) as! ArticleVC
            
            desVC.navigationTitle = category
            desVC.category = categoryKey
            
            self.navigationController?.pushViewController(desVC, animated: true)
            childMass.removeAll()
        }
    }
}

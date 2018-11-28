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

//TODO: Move to singleton 
var savedArticles = [Article]()

struct categoriessss {
    var name: String
    var key: String?
    
    init?(name: String?, key: String?) { guard let name = name else { return nil}
        self.name = name
        self.key = key
    }
}

class ViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var bannerView: GADBannerView!
    
    let tableViewCellHeight: Int = 70
    
    var categories = Feed()
    
    var category: String?
    var categoriesMass = [String]()
    var keyMass = [String]()
    
    var childMass = [String]()
    var childKeyMass = [String]()
    
    //var categoriesObject = categoriessss()
    //var categoriesMasss = []()
    var categoriesMasss: [categoriessss] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "BlackStar"), style: .plain, target: self, action: #selector(addTapped))
        
        categoriesMass = getData(category: "_root")
        
        self.categoriesMasss = categoriesMasss.sorted { $0.name > $1.name }
        
        setupTableView()
        sorting()
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
            savedArticles = article
        } catch {
            print("Error in fetching CoreData")
        }
        
        self.navigationController?.pushViewController(desVC, animated: true)
    }
    
    //Get Data
    
    func getData(category: String) -> [String] {
        
        var categoriesMass = [String]()
        
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
                                //categoriesMass.append(name)
                                var elem = categoriessss(name: name, key: k)
                                //                                elem.name = name
                                //                                elem.key = k
                                
                                if let element = elem {
                                    categoriesMasss.append(element)
                                    
                                }
                                //                                categoriesObject.name = name
                                //                                categoriesObject.key = k
                            }
                            
                            //keyMass.append(k)
                            
                            //                            if (category != "_root") {
                            //                                childKeyMass.append(k)
                            //                            }
                        }
                    }
                }
                
            } catch {
                print("ERROR:", error)
            }
        }
        
        return categoriesMass
    }
    
    //Func Sorting
    
    func sorting() {
        //dictionary = dictionary.sorted { $0.value < $1.value }
        //let sortedDictionary = dictionary.keys.sorted{dictionary[$0]! < dictionary[$1]!}
    }
    
    //TODO: Move it + rename
    struct Objects {
        var sectionName: String!
        var sectionObjects: String!
    }
    
    var objectArray = [Objects]()
    
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
        return categoriesMasss.count//categoriesMass.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewCellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RootCell.identifier, for: indexPath) as! RootCell
        
        let data = categoriesMasss[indexPath.row]
        
        cell.rootLabel?.text = data.name
        cell.rootImage.image = UIImage(named: data.key!)
        cell.arroyImage.image = UIImage(named: "arroy") //TODO: Rename
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        searchingCategories(categoryKey: categoriesMasss[indexPath.item].key!, category: categoriesMasss[indexPath.item].name)
    }
    
    //Searching Child Categories
    
    func searchingCategories(categoryKey: String, category: String) {
        
        childMass = getData(category: categoryKey)
        
        if childMass.count != 0 {
            //TODO: use identifier
            let desVC = storyboard?.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesVC
            
            desVC.navigationTitle = category
            
            desVC.categoriesMass = childMass
            desVC.keyMass = childKeyMass
            
            self.navigationController?.pushViewController(desVC, animated: true)
            
            childMass.removeAll()
            childKeyMass.removeAll()
        } else {
            //TODO: use identifier
            let desVC = storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as! ArticleVC
            
            desVC.navigationTitle = category
            desVC.category = categoryKey
            
            self.navigationController?.pushViewController(desVC, animated: true)
            childMass.removeAll()
            childKeyMass.removeAll()
        }
    }
}

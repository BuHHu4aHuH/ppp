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
//TODO: Rename
var dictionary = [String: String]()

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "BlackStar"), style: .plain, target: self, action: #selector(addTapped))
        
        categoriesMass = getData(category: "_root")
        setupTableView()
        sorting()
        
        //TODO: add func
        for (key, value) in dictionary {
            objectArray.append(Objects(sectionName: key, sectionObjects: value))
        }
        
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
                    //MARK: asdasd
                    for (k, v) in dict {
                        
                        //TODO: Use guard let
                        if let parent = v.parent, parent == category {
                            
                            
                            if let name = v.name {
                                categoriesMass.append(name)
                                dictionary.updateValue(name, forKey: k)
                            }
                            //dictionary[parent] = v.name
                            
                            keyMass.append(k)
                            
                            if (category != "_root") {
                                childKeyMass.append(k)
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
        return categoriesMass.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewCellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RootCell.identifier, for: indexPath) as! RootCell
        
        let data = categoriesMass[indexPath.row]
        
        cell.rootLabel?.text = data//objectArray[indexPath.item].sectionObjects
        cell.rootImage.image = UIImage(named: keyMass[indexPath.item])//objectArray[indexPath.item].sectionName)
        cell.arroyImage.image = UIImage(named: "arroy") //TODO: Rename
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        searchingCategories(categoryKey: keyMass[indexPath.item], category: categoriesMass[indexPath.item])
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

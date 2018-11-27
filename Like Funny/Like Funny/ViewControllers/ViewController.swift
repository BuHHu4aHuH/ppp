//
//  ViewController.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/4/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import CoreData

var savedArticles = [Article]()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let tableViewCellHeight: Int = 70
    
    var categories = Feed()
    
    var category: String?
    var categoriesMass = [String]()
    var keyMass = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "BlackStar"), style: .plain, target: self, action: #selector(addTapped))
    
        categoriesMass = getData(category: "_root")
        setupTableView()
    }
    
    //Get Data
    
    @objc func addTapped() {
        let desVC = storyboard?.instantiateViewController(withIdentifier: "SavedArticlesController") as! SavedArticlesController
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        do {
            let article = try PersistenceServce.context.fetch(fetchRequest)
            savedArticles = article
        } catch {
            print("Error in fetching CoreData")
        }
        
        self.navigationController?.pushViewController(desVC, animated: true)
    }
    
    func getData(category: String) -> [String] {
        var categoriesMass = [String]()
        
        DataService.shared.getData { (data) in
            do {
                let decoder = JSONDecoder()
                self.categories = try decoder.decode(Feed.self, from: data)
                
                if let dict = categories.categories {
                    
                    for (k, v) in dict {
                        
                        if let parent = v.parent {
                            if (parent == category) {
                                if let name = v.name {  categoriesMass.append(name) }
                                keyMass.append(k)
                                if (category != "_root") {
                                    childKeyMass.append(k)
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
    
    //TableView
    
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
        
        cell.rootLabel?.text = data
        cell.rootImage.image = UIImage(named: keyMass[indexPath.item])
        cell.arroyImage.image = UIImage(named: "arroy")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        searchingCategories(categoryKey: keyMass[indexPath.item], category: categoriesMass[indexPath.item])
    }
    
    var childMass = [String]()
    var childKeyMass = [String]()
    
    func searchingCategories(categoryKey: String, category: String) {
       childMass = getData(category: categoryKey)
        if (childMass.count != 0) {
            let desVC = storyboard?.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesVC
            
            desVC.navigationTitle = category
            
            desVC.categoriesMass = childMass
            desVC.keyMass = childKeyMass
            
            self.navigationController?.pushViewController(desVC, animated: true)
            
            childMass.removeAll()
            childKeyMass.removeAll()
        } else {
            let desVC = storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as! ArticleVC
            
            desVC.navigationTitle = category
            desVC.category = categoryKey
            
            self.navigationController?.pushViewController(desVC, animated: true)
            childMass.removeAll()
            childKeyMass.removeAll()
        }
    }
}

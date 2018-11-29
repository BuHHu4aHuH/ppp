//
//  CategoriesVC.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/5/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit

class CategoriesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var navigationTitle: String?
    let tableViewCellHeight: Int = 70
    
    var categories = Feed()
    var categoriesMass = [String]()
    var keyMass = [String]()
    
    var childMass = [WorkWithDataSingleton.categoriesModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navigationTitle

        setupTableView()
    }
    
    func getData(category: String) {
        DataService.getData { (data) in
            do {
                let decoder = JSONDecoder()
                self.categories = try decoder.decode(Feed.self, from: data)
                
                if let dict = categories.categories {
                    
                    for (k, v) in dict {
                        
                        if let parent = v.parent {
                            if parent == category {
                                if let name = v.name {
                                    let elem = WorkWithDataSingleton.categoriesModel(name: name, key: k)
                                    
                                    if let element = elem {
                                        childMass.append(element)
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
        
        cell.txtLabel?.text = data
        cell.arroyImage.image = UIImage(named: "arroy")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        searchingCategories(categoryKey: keyMass[indexPath.item], category: categoriesMass[indexPath.item])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewCellHeight)
    }
    
    //Searching Child Categories
    
    func searchingCategories(categoryKey: String, category: String) {
        getData(category: categoryKey)
        self.childMass = childMass.sorted { $0.name > $1.name }
        
        if childMass.count != 0 {
            let desVC = storyboard?.instantiateViewController(withIdentifier: CategoriesChildVC.identifier) as! CategoriesChildVC
            
            let names = childMass.map { $0.name }
            let keys = childMass.map { $0.key }
            
            desVC.navigationTitle = category
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

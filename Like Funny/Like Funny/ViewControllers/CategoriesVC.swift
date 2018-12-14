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
    
    var categories = Feed()
    
    var categoryKeyy: String?
   
    var categoriesMass = [WorkWithDataSingleton.categoriesModel]()
    
    var childMass = [WorkWithDataSingleton.categoriesModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navigationTitle
        
        categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: categoryKeyy!)
        
        self.categoriesMass = categoriesMass.sorted { $0.name > $1.name }

        setupTableView()
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
        
        childMass = SQLiteArticleSingleton.readingData(categorySearching: categoriesMass[indexPath.item].key!)
        
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
        return CGFloat(UIViewController.tableViewCellHeight)
    }
}

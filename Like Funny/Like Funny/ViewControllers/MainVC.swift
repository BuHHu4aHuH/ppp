//
//  MainVC
//  Like Funny
//
//  Created by Maksim Shershun on 11/4/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import CoreData
//import GoogleMobileAds
import SQLite
import Firebase

class MainVC: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    //var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.categoriesMass.sorted { $0.name > $1.name }
        
        bannerView.adUnitID = "ca-app-pub-9685005451826961/7782646746"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        setupTableView()
        setupNavBar()
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Favorite"), style: .plain, target: self, action: #selector(addTapped)) 
    }
    
    //Setup Banner

    
    
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
    
}

//MARK: - TableView
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibName = UINib(nibName: RootCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: RootCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SQLiteArticleSingleton.categoriesMass.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(UIViewController.tableViewCellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RootCell.identifier, for: indexPath) as! RootCell
        
        let data = SQLiteArticleSingleton.categoriesMass[indexPath.row]
        
        cell.rootLabel?.text = data.name
        cell.rootImage.image = UIImage(named: data.key!)
        cell.arroyImage.image = UIImage(named: "arroy") //TODO: Rename
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if SQLiteArticleSingleton.categoriesMass[indexPath.item].key == "ukrajinski-privitannya" {
            let desVC = storyboard?.instantiateViewController(withIdentifier: ArticleVC.identifier) as! ArticleVC
            
            desVC.navigationTitle = SQLiteArticleSingleton.categoriesMass[indexPath.item].name
            desVC.category = SQLiteArticleSingleton.categoriesMass[indexPath.item].key
            
            self.navigationController?.pushViewController(desVC, animated: true)
        } else {
            let desVC = storyboard?.instantiateViewController(withIdentifier: CategoriesVC.identifier) as! CategoriesVC
            
            desVC.navigationTitle = SQLiteArticleSingleton.categoriesMass[indexPath.item].name
            desVC.categoryKeyy = SQLiteArticleSingleton.categoriesMass[indexPath.item].key
            
            self.navigationController?.pushViewController(desVC, animated: true)
        }
    }
}

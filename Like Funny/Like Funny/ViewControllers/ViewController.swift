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
import NVActivityIndicatorView

class ViewController: UIViewController, GADBannerViewDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var tableView: UITableView!
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Favorite"), style: .plain, target: self, action: #selector(addTapped))
        
        SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.categoriesMass.sorted { $0.name > $1.name }
        
        setupTableView()
        
        //setupBanner()
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

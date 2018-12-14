//
//  ArticleVC.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/17/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import CoreData
import SQLite

class ArticleVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var navigationTitle: String?
    
    var category: String?
    var categoriesMass = Feed()
    var textsArray = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadTableWithAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        textsArray = readingData(categorySearching: category!)
        
        fetchRequest()
        setupTableView()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Favorite"), style: .plain, target: self, action: #selector(addTapped))
    }
    
    //Fetch Request
    
    func fetchRequest() {
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        do {
            let article = try PersistenceServce.context.fetch(fetchRequest)
            WorkWithDataSingleton.savedArticles = article
        } catch {
            
        }
    }
    
    //Open Saved ViewController
    
    @objc func addTapped() {
        let desVC = storyboard?.instantiateViewController(withIdentifier: "SavedArticlesController") as! SavedArticlesController
        
        self.navigationController?.pushViewController(desVC, animated: true)
    }
    
    //Deinit old textArray
    
    deinit {
        textsArray.removeAll()
    }
    
    //Alert
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated:  true, completion: nil)
    }
    
    //ReadData from SQLite
    
    func readingData(categorySearching: String) -> [String] {
        var categoriesModel = [String]()
        
        do {
            let articles = try SQLiteArticleSingleton.articleDatabase.prepare(SQLiteArticleSingleton.articleTable)
            for article in articles {
                if article[SQLiteArticleSingleton.articleKey] == categorySearching {
                    categoriesModel.append(article[SQLiteArticleSingleton.textArticleTable])
                }
            }
            
        } catch {
            print(error)
        }
        
        return categoriesModel
    }
    
    func reloadTableWithAnimation() {
        
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }
}

extension ArticleVC: UITableViewDelegate, UITableViewDataSource {
    
    //TableView
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
        
        let nibName = UINib(nibName: ArticleCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: ArticleCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath) as! ArticleCell
        
        cell.prepareForReuse()
        
        cell.articleLabel.text = textsArray[indexPath.item]
        
        let image = cell.setupSaveButton(isSaved: false)
        cell.saved.setImage(image, for: .normal)
        
        for saved in WorkWithDataSingleton.savedArticles {
            if cell.articleLabel.text == saved.article {
                let image = cell.setupSaveButton(isSaved: true)
                cell.saved.setImage(image, for: .normal)
            }
        }
        
        cell.selectionStyle = .none
        
        cell.sharingSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            let textShare = self.textsArray[indexPath.item]
            let activityViewController = UIActivityViewController(activityItems: [textShare], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        cell.saveToCoreDataSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            var imageForButton: UIImage
            
            if cell.saved.imageView?.image == UIImage(named: "BlackStar95") {
                imageForButton = cell.setupSaveButton(isSaved: false)
                cell.saved.setImage(imageForButton, for: .normal)
                
                for article in WorkWithDataSingleton.savedArticles {
                    if article.article == self.textsArray[indexPath.item] {
                        PersistenceServce.persistentContainer.viewContext.delete(article)
                    }
                }
                
                WorkWithDataSingleton.savedArticles.removeAll(where: { (article) -> Bool in
                    article.article == self.textsArray[indexPath.item]
                })
                
                PersistenceServce.saveContext()
                
            } else {
                imageForButton = cell.setupSaveButton(isSaved: true)
                cell.saved.setImage(imageForButton, for: .normal)
                
                let article = Article(context: PersistenceServce.context)
                article.article = self.textsArray[indexPath.item]
                PersistenceServce.saveContext()
                
                WorkWithDataSingleton.savedArticles.append(article)
            }
        }
        
        cell.copyTextSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            UIPasteboard.general.string = self.textsArray[indexPath.item]
            
            self.createAlert(title: "Warning", message: "Here will be text soon...")
        }
        
        return cell
    }
}

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
    
    let tableViewCellHeight: Int = 150
    
    var navigationTitle: String?
    
    var articlesAmount = 0
    
    var category: String?
    var categoriesMass = Feed()
    var textsArray = [String]()
    
    //SQLite Database
    
    var categoriesDatabase: Connection!
    
    let categoriesTable = Table("categories")
    let idCategoriesTable = Expression<Int>("id")
    let nameCategoriesTable = Expression<String>("name")
    let parentCategoriesTable = Expression<String>("parent")
    let keyCategoriesTable = Expression<String>("key")
    
    
    var articleDatabase: Connection!
    
    let articleTable = Table("article")
    let idArticleTable = Expression<Int>("id")
    let textArticleTable = Expression<String>("text")
    let articleKey = Expression<String>("key")
    let isSaved = Expression<Bool>("isSaved")
    
    
    var categoriesArticleDatabase: Connection!
    
    let categoriesArticleTable = Table("categoriesArticle")
    let categoryKey = Expression<String>("key")
    let articleId = Expression<Int>("articleId")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: add func setupNavBar()
        self.navigationItem.title = navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Favorite"), style: .plain, target: self, action: #selector(addTapped))
        
        setupTables()
        createTables()
        
        //getData()
        
        textsArray = readingData(categorySearching: category!)
        
        print("SSSSSSSEEEEEEEEAAAAAARRRRRRRCCCCCCHHHHHHH")
        print(category)
        print(textsArray.count)
        print("lol")
        print("articlesAmount: \(articlesAmount)")
        print("lol")
        
        fetchRequest()
        //getData()
        setupTableView()
    }
    
    func setupTables() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("categories").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.categoriesDatabase = database
        } catch {
            print(error)
        }
        
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("article").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.articleDatabase = database
        } catch {
            print(error)
        }
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("categoriesArticle").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.categoriesArticleDatabase = database
        } catch {
            print(error)
        }
        
    }
    
    //Create DB
    
    func createTables() {
        print("CREATE TABLE")
        
        //CategoriesTable
        
        let createCategoriesTable = self.categoriesTable.create { (table) in
            table.column(self.idCategoriesTable, primaryKey: true)
            table.column(self.parentCategoriesTable)
            table.column(self.keyCategoriesTable)
            table.column(self.nameCategoriesTable)
        }
        
        do {
            try self.categoriesDatabase.run(createCategoriesTable)
            print("CREATED CATEGORIES TABLE")
        } catch {
            print(error)
        }
        
        //ArticleTable
        
        let createArticleTable = self.articleTable.create { (table) in
            table.column(self.idArticleTable, primaryKey: true)
            table.column(self.textArticleTable)
            table.column(self.articleKey)
            table.column(self.isSaved)
        }
        
        do {
            try self.articleDatabase.run(createArticleTable)
            print("CREATED ARTICLE TABLE")
        } catch {
            print(error)
        }
        
        //CategoriesArticleTable
        
        let createCategoriesArticleTable = self.categoriesArticleTable.create { (table) in
            table.column(self.categoryKey, primaryKey: true)
            table.column(self.articleId, primaryKey: true)
        }
        
        do {
            try self.categoriesArticleDatabase.run(createCategoriesArticleTable)
            print("CREATED CATEGORIESARTICLE TABLE")
        } catch {
            print(error)
        }
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
            let articles = try self.articleDatabase.prepare(self.articleTable)
            for article in articles {
                if article[self.articleKey] == categorySearching {
                    categoriesModel.append(article[self.textArticleTable])
                }
                articlesAmount = articlesAmount + 1
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
        
        let amountOfSavedArticles = WorkWithDataSingleton.savedArticles.count
        var i = 0
        
        if amountOfSavedArticles == 0 {
            print("nothing saved")
        } else {
            repeat {
                if cell.articleLabel.text == WorkWithDataSingleton.savedArticles[i].article {
                    let image = cell.setupSaveButton(isSaved: true)
                    cell.saved.setImage(image, for: .normal)
                }
                i = i + 1
            } while i < amountOfSavedArticles
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
                
                //let article = WorkWithDataSingleton.savedArticles[indexPath.item]
                //PersistenceServce.persistentContainer.viewContext.delete(WorkWithDataSingleton.savedArticles[indexPath.item])
                //WorkWithDataSingleton.savedArticles.remove(at: indexPath.item)
            } else {
                imageForButton = cell.setupSaveButton(isSaved: true)
                cell.saved.setImage(imageForButton, for: .normal)
                
                let article = Article(context: PersistenceServce.context)
                article.article = self.textsArray[indexPath.item]
                PersistenceServce.saveContext()
                
                WorkWithDataSingleton.savedArticles.append(article)
            }
            
            //self.reloadTableWithAnimation()
            
        }
        
        cell.copyTextSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            UIPasteboard.general.string = self.textsArray[indexPath.item]
            
            self.createAlert(title: "Warning", message: "Here will be text soon...")
        }
        
        return cell
    }
}

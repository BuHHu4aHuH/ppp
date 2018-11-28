//
//  ArticleVC.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/17/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import CoreData

class ArticleVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let tableViewCellHeight: Int = 150
    
    var navigationTitle: String?
    
    var category: String?
    var categoriesMass = Feed()
    var textsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: add func setupNavBar()
        self.navigationItem.title = navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "BlackStar95"), style: .plain, target: self, action: #selector(addTapped))
        
        fetchRequest()
        getData()
        setupTableView()
    }
    
    //Fetch Request
    
    func fetchRequest() {
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        do {
            let article = try PersistenceServce.context.fetch(fetchRequest)
            savedArticles = article
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
    
    //Get Data
    //TODO: NEED TO REFACTORING!!!!!!!!!!!!!!!!!!!!
    func getData() {
        DataService.getData { (data) in
            do {
                let decoder = JSONDecoder()
                self.categoriesMass = try decoder.decode(Feed.self, from: data)
                
                if let dict2 = categoriesMass.items {
                    for (k, v) in dict2 {
                        
                        if let categories = v.categories {
                            let amountOfCategories = categories.count
                            var i = 0
                            repeat {
                                if (category == categories[i]) {
                                    if let elements = v.elements {
                                        let amountOfElements = elements.count
                                        var j = 0
                                        
                                        repeat {
                                            
                                            let heshKey = elements.keys
                                            let dataDict = elements[heshKey.first!]
                                            if let data = dataDict?.data {
                                                if let zero = data.zero {
                                                    if let value = zero.value {
                                                        let cleanValue = value.replacingOccurrences(of: "<[^>]+>", with: "\n", options: .regularExpression, range: nil)
                                                        let cleaningSecond = cleanValue.replacingOccurrences(of: "&#39;", with: "'", options: .regularExpression, range: nil)
                                                        let cleaningThird = cleaningSecond.replacingOccurrences(of: "&nbsp;", with: "", options: .regularExpression, range: nil)
                                                        let cleaningForth = cleaningThird.replacingOccurrences(of: "&quot;", with: "\"" , options: .regularExpression, range: nil)
                                                        let cleaningFifth = cleaningForth.replacingOccurrences(of: "&mdash;", with: "-", options: .regularExpression, range: nil)
                                                        let cleaningSixth = cleaningFifth.replacingOccurrences(of: "&ndash;", with: "-", options: .regularExpression, range: nil)
                                                        let cleaningSeventh = cleaningSixth.replacingOccurrences(of: "&rsquo;", with: "’", options: .regularExpression, range: nil)
                                                        textsArray.append(cleaningSeventh)
                                                    }
                                                }
                                            }
                                            if (amountOfElements >= 2) {
                                                break
                                            } else {
                                                j = j + 1;
                                            }
                                            
                                        } while (j < amountOfElements)
                                        
                                        
                                    }
                                    break;
                                }
                                i = i + 1;
                            } while (i < amountOfCategories)
                        }
                    }
                }
                
            } catch {
                print("ERROR:", error)
            }
        }
    }
    
    //Alert
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated:  true, completion: nil)
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
        
        cell.articleLabel.text = textsArray[indexPath.item]
        
        cell.saved.imageView?.image = UIImage(named: "WhiteStar95")

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
            
            //TODO: Change this to setupSaveButton(isSaved: Bool)
            cell.saved.setImage(UIImage(named: "BlackStar95"), for: .normal)
            
            let article = Article(context: PersistenceServce.context)
            article.article = self.textsArray[indexPath.item]
            PersistenceServce.saveContext()
            savedArticles.append(article)
        }
        
        cell.copyTextSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            UIPasteboard.general.string = self.textsArray[indexPath.item]
            
            self.createAlert(title: "Warning", message: "Here will be text soon...")
        }
        
        return cell
    }
}

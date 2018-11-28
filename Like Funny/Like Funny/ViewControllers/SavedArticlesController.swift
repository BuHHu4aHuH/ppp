//
//  SavedArticlesController.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/25/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import CoreData

class SavedArticlesController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Сохраненные"
        
        setupTableView()
    }
    
    //Alert
    
    func createAlert (title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated:  true, completion: nil)
    }
}

extension SavedArticlesController: UITableViewDelegate, UITableViewDataSource {
    
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
        return savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath) as! ArticleCell
        
        cell.articleLabel.text = savedArticles[indexPath.item].article
        
        cell.selectionStyle = .none
        cell.saved.setImage(UIImage(named: "BlackStar95"), for: .normal)
        
        cell.sharingSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            let textShare = savedArticles[indexPath.item].article
            let activityViewController = UIActivityViewController(activityItems: [textShare], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        cell.saveToCoreDataSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            let article = savedArticles[indexPath.item]
            PersistenceServce.persistentContainer.viewContext.delete(article)
            savedArticles.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            PersistenceServce.saveContext()
        }
        
        cell.copyTextSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            UIPasteboard.general.string = savedArticles[indexPath.item].article
            
            self.createAlert(title: "Warning", message: "Here will be text soon...")
            
        }
        return cell
    }
}

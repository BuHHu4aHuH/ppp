//
//  SavedArticlesController.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/25/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class SavedArticlesController: UIViewController {
    
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkOnSaved()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Сохраненные"
        
        setupTableView()
        setupBanner()
    }
    
    //Check if smth saved
    
    func checkOnSaved() {
        if WorkWithDataSingleton.savedArticles.isEmpty {
            tableView.backgroundView = imageView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    //MARK: Setup Banner
    
    func setupBanner() {
        bannerView.adUnitID = "ca-app-pub-9685005451826961/7782646746"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    //Alert
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Соглас(на/ен)", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Нет", style: .destructive, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated:  true, completion: nil)
    }
    
    func reloadTableWithAnimation() {
        
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
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
        return WorkWithDataSingleton.savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath) as! ArticleCell
        
        cell.articleLabel.text = WorkWithDataSingleton.savedArticles[indexPath.item].article
        
        cell.selectionStyle = .none
        
        cell.setupRemoveImage()
        
        cell.sharingSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            let textShare = WorkWithDataSingleton.savedArticles[indexPath.item].article
            let activityViewController = UIActivityViewController(activityItems: [textShare], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        cell.saveToCoreDataSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            let article = WorkWithDataSingleton.savedArticles[indexPath.item]
            PersistenceServce.persistentContainer.viewContext.delete(article)
            WorkWithDataSingleton.savedArticles.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            PersistenceServce.saveContext()
            self.reloadTableWithAnimation()
            self.checkOnSaved()
        }
        
        cell.copyTextSwitchHandler = { [weak self] in
            
            guard let `self` = self else { return }
            
            UIPasteboard.general.string = WorkWithDataSingleton.savedArticles[indexPath.item].article
            
            self.createAlert(title: "Пользовательское соглашение и правила копирования", message: "1. Настоящее Соглашение является публичной офертой. Получая доступ к поздравлениям данного приложения, Пользователь считается присоединившимся к настоящему Соглашению. \n2. Никакой Контент не может быть скопирован (воспроизведен), переработан, распространен, опубликован или иным способом использован целиком или по частям, без указанния источника. \n3. В случае необходимости использования текстовых  материалов, права на которые принадлежат нашим авторам, Пользователям необходимо обращаться через обратную связь www.likefunny.org. \n4. При копировании прямая ссылка на сайт и указание авторов обязательна! Копирование в коммерческих целях допускается только при письменном разрешении администрации сайта www.likefunny.org.")
        }
        
        return cell
    }
}

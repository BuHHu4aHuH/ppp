//
//  ShowSplashScreen.swift
//  Like Funny
//
//  Created by Maksim Shershun on 12/13/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import JTMaterialSpinner

class ShowSplashScreen: UIViewController {
    
    @IBOutlet weak var spinnerView: JTMaterialSpinner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupDataToStorage()
    }
    
    func setupDataToStorage() {
        
        SQLiteArticleSingleton.setupTables()
        SQLiteArticleSingleton.createTables()
        
        SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: "_root")
        
        if UserDefaults.standard.bool(forKey: "isDownloaded") {
            
            RunLoop.current.run(until: Date(timeIntervalSinceNow : 1.0))
            self.showMainVC()
            
        } else {
            
            try! SQLiteArticleSingleton.categoriesDatabase.run(SQLiteArticleSingleton.categoriesTable.delete())
            try! SQLiteArticleSingleton.articleDatabase.run(SQLiteArticleSingleton.articleTable.delete())
            
            // Customize the line width
            spinnerView.circleLayer.lineWidth = 4.0
            
            // Change the color of the line
            spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
            
            // Change the duration of the animation
            spinnerView.animationDuration = 3
            
            spinnerView.beginRefreshing()
            
            DispatchQueue.global().async() {
                
                SQLiteArticleSingleton.getData()
                SQLiteArticleSingleton.getDataArticles()
                UserDefaults.standard.set(true, forKey: "isDownloaded")
                SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: "_root")
                self.spinnerView.endRefreshing()
                self.showMainVC()
            }
            
        }
    }
    
    func showMainVC() {
        DispatchQueue.main.async {
            let navVC = self.storyboard?.instantiateViewController(withIdentifier: "NavVC") as! UINavigationController
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
}

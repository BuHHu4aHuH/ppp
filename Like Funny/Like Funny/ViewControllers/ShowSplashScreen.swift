//
//  ShowSplashScreen.swift
//  Like Funny
//
//  Created by Maksim Shershun on 12/13/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class ShowSplashScreen: UIViewController {
    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProgressView()
        setupDataToStorage()
    }
    
    func setupProgressView() {
        progressView.value = 0
        progressView.isHidden = true
    }
    
    func startProgressView() {
        DispatchQueue.main.async {
            
            self.progressView.isHidden = false
            
            UIView.animate(withDuration: 10.0) {
                self.progressView.value = 100
            }
        }
    }
    
    func setupDataToStorage() {
        
        SQLiteArticleSingleton.setupTables()
        SQLiteArticleSingleton.createTables()
        
        SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: "_root")
        
        if SQLiteArticleSingleton.categoriesMass.isEmpty {
            
            startProgressView()
            
            DispatchQueue.global().async() {
                
                SQLiteArticleSingleton.getData() {
                    SQLiteArticleSingleton.getDataArticles() {
                        SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: "_root")
                        
                        self.showMainVC()
                    }
                }
            }
        } else {
            self.showMainVC()
        }
    }
    
    func showMainVC() {
        DispatchQueue.main.async {
            let navVC = self.storyboard?.instantiateViewController(withIdentifier: "NavVC") as! UINavigationController
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
}

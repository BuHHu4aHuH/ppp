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
        
        self.progressView.value = 0
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.performSegue(withIdentifier: "showSplashScreen", sender: nil)
            
            SQLiteArticleSingleton.setupTables()
            SQLiteArticleSingleton.createTables()
            
            SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: "_root")
            
            if SQLiteArticleSingleton.categoriesMass.count == 0 {
                UIView.animate(withDuration: 10.0) {
                    self.progressView.value = 100
                }
                
                SQLiteArticleSingleton.getData()
                SQLiteArticleSingleton.getDataArticles()
                SQLiteArticleSingleton.categoriesMass = SQLiteArticleSingleton.readingData(categorySearching: "_root")
            }
        }
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        UIView.animate(withDuration: 10.0) {
//            self.progressView.value = 100
//        }
//    }
    
}

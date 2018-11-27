//
//  CategoriesChildVC.swift
//  Like Funny
//
//  Created by Maksim Shershun on 11/21/18.
//  Copyright © 2018 Maksim Shershun. All rights reserved.
//

import UIKit

class CategoriesChildVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    
    var navigationTitle: String?
    let tableViewCellHeight: Int = 70
    
    var categoriesMass = [String]()
    var keyMass = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navigationTitle
        
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        let nibName = UINib(nibName: CategoryCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: CategoryCell.identifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesMass.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell

        let data = categoriesMass[indexPath.row]

        cell.txtLabel?.text = data
        cell.arroyImage.image = UIImage(named: "arroy")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let desVC = storyboard?.instantiateViewController(withIdentifier: "ArticleVC") as! ArticleVC

        desVC.navigationTitle = categoriesMass[indexPath.item]
        desVC.category = keyMass[indexPath.item]

        self.navigationController?.pushViewController(desVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewCellHeight)
    }
}

//
//  SearchViewController.swift
//  Kitchen Diaries
//
//  Created by Nimesh Johri on 5/23/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var searchBox: UITextField!

    @IBAction func searchButton(_ sender: Any) {
        let searchTerm = searchBox.text
        let selectedController = tabBarController?.viewControllers![0]
        if (selectedController is HomeViewController) {
            let home = selectedController as! HomeViewController
            home.responseFromUser(searchTerm: searchTerm!)
        }
        searchBox.text = ""
        tabBarController?.selectedIndex = 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

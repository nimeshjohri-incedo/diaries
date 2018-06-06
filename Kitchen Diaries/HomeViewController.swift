//
//  HomeViewController.swift
//  Kitchen Diaries
//
//  Created by Nimesh Johri on 5/23/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SDWebImage

class categoriesTableViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
}

var webURL = ""
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var tableArray = [String] ()
    var globalSearch = ""
    var sortType = "t"
    
    @IBAction func sortButton(_ sender: Any) {
        if(sortType == "r") {
            sortType = "t"
        } else {
          sortType = "r"
        }
        apiDataFetch()
    }
    func responseFromUser(searchTerm: String) {
        globalSearch = searchTerm
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionLabelCell",for: indexPath) as! categoriesTableViewCell
        var dict = arrRes[indexPath.row]
        cell.headLabel?.text = dict["title"] as? String
        let urlString = dict["image_url"]
        webURL = dict["source_url"] as! String
        let url = URL(string: urlString as! String )
        if(url != nil) {
            cell.foodImage?.sd_setImage(with: url, placeholderImage:UIImage(named: "boardTextArea.png"))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "recipeWebView", sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 310.0;//Choose your custom row height
    }
    @IBOutlet weak var HomeTiles: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func apiDataFetch() {
        startAnimating(CGSize(width: 60, height: 60), message: "Serving.. Just a second")
        self.HomeTiles!.register(categoriesTableViewCell.self, forCellReuseIdentifier: "categoriesTableViewCell")
        var apiURL = String()
        apiURL = "https://food2fork.com/api/search?key=db6356d5fea03017abb29532c24a4090&q=\(globalSearch)&sort=\(sortType)"
        print(apiURL)
        Alamofire.request(apiURL).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["recipes"].arrayObject {
                    self.arrRes = resData as! [[String:AnyObject]]
                    //print(self.arrRes)
                }
                if self.arrRes.count > 0 {
                    self.HomeTiles.reloadData()
                }
                self.stopAnimating()
            }
        }
        self.HomeTiles.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        apiDataFetch()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

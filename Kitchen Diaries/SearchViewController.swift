//
//  SearchViewController.swift
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

class searchTableViewCell: UITableViewCell {
    @IBOutlet weak var searchCellView: UIView!
    @IBOutlet weak var searchResultImage: UIImageView!
    @IBOutlet weak var searchResultLabel: UILabel!
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var tableArray = [String] ()
    var globalSearch = ""
    var sortType = "t"
    var scrollStatus = 1
    var loadingData = false
    @IBOutlet weak var cellTableView: UITableView!
    @IBOutlet weak var searchTerm: UISearchBar!
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        globalSearch = (searchTerm?.text)!
        apiDataFetch(pageOffset: scrollStatus)
        // cellTableView.reloadData()
        self.view.endEditing(true)
    }
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCells",for: indexPath) as! searchTableViewCell
        var dict = arrRes[indexPath.row]
        cell.searchResultLabel?.text = dict["title"] as? String
        let urlString = dict["image_url"]
        webURL = dict["source_url"] as! String
        let url = URL(string: urlString as! String )
        if(url != nil) {
            cell.searchResultImage?.sd_setImage(with: url, placeholderImage:UIImage(named: "boardTextArea.png"))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "searchResultView", sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0;//Choose your custom row height
    }
    func apiDataFetch(pageOffset: Int) {
        startAnimating(CGSize(width: 60, height: 60), message: "Serving.. Just a second")
        self.cellTableView!.register(searchTableViewCell.self, forCellReuseIdentifier: "searchTableViewCell")
        var apiURL = String()
        apiURL = "https://food2fork.com/api/search?key=db6356d5fea03017abb29532c24a4090&q=\(globalSearch)&page=\(pageOffset)"
        print(apiURL)
        Alamofire.request(apiURL).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["recipes"].arrayObject {
                    if(self.loadingData == true) {
                        self.arrRes.append(contentsOf: resData as! [[String:AnyObject]])
                    } else {
                        self.arrRes = resData as! [[String:AnyObject]]
                    }
                    print(self.arrRes.count)
                    //print(self.arrRes)
                }
                if self.arrRes.count > 0 {
                    self.cellTableView.reloadData()
                }
                self.stopAnimating()
            }
        }
        self.cellTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = arrRes.count - 1
        if indexPath.row == lastElement {
            if( loadingData == false) {
                loadingData = true
                scrollStatus = scrollStatus + 1
                apiDataFetch(pageOffset: scrollStatus)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTerm.delegate = self
        cellTableView.delegate = self
        cellTableView.dataSource = self
        self.searchTerm.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

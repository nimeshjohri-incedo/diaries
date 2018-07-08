import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SDWebImage
import GoogleMobileAds

protocol searchTableViewCellDelegate:AnyObject {
    func didSelectButton(indexNumber:Int?) -> Void
}

class searchTableViewCell: UITableViewCell {
    @IBOutlet weak var searchCellView: UIView!
    @IBOutlet weak var searchResultImage: UIImageView!
    @IBOutlet weak var searchResultLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    var indexNumber :Int?
    var isSelectedCell :Bool?
    var image_name = "heart outline blank"
    weak var delegate:searchTableViewCellDelegate?
    @IBAction func likeButton(_ sender: UIButton) {
        if self.delegate != nil {
            //            if (self.delegate?.responds(to: #selector(categoriesTableViewCellDelegate.didSelectButton(indexNumber))))! {
            self.delegate?.didSelectButton(indexNumber: self.indexNumber)
            if(self.image_name == "heart outline filled") {
                self.image_name = "heart outline blank"
            } else {
                self.image_name = "heart outline filled"
            }
            sender.setImage(UIImage(named: self.image_name), for: .normal)
        }
        //      }
    }
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, searchTableViewCellDelegate {
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
    
    func checkIsAddedOnFavorite(recipeId: String?) -> Bool {
        var isFound = false
        if let recipeId = recipeId {
            for dictionary in favoriteArray {
                if dictionary["recipe_id"] as? String == recipeId {
                    isFound = true
                    break
                }
            }
        }
        return isFound
    }
    
    func removeFromFavorite(recipeId: String?) -> Void {
        var indexNumber:Int?
        if let recipeId = recipeId {
            for (index, element) in favoriteArray.enumerated(){
                if element["recipe_id"] as? String == recipeId {
                    indexNumber = index
                    break
                }
            }
        }
        if indexNumber != nil {
            favoriteArray.remove(at: indexNumber!)
        }
    }
    
    func didSelectButton(indexNumber:Int?) -> Void{
        let selected = arrRes[indexNumber!]
        let size = favoriteArray.count
        if size > 0 {
            if !self.checkIsAddedOnFavorite(recipeId: selected["recipe_id"] as? String){
                favoriteArray.append(selected)
            }
            else{
                self.removeFromFavorite(recipeId: selected["recipe_id"] as? String)
            }
        } else {
            favoriteArray.append(selected)
        }
        UserDefaults.standard.set(favoriteArray, forKey: "Key")
    }
    
    private func isAddedOnFavorite(item:[String:AnyObject]) -> Bool {
        var isFound = false
        for dictionary in favoriteArray {
            if item["recipe_id"] as? String == dictionary["recipe_id"] as? String {
                isFound = true
                break
            }
        }
        return isFound
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if((UserDefaults.standard.object(forKey: "Key")) != nil) {
            let returnValue = UserDefaults.standard.object(forKey: "Key") as! [[String:AnyObject]]
            let parsedFavoriteArray = Array(returnValue)
            favoriteArray = parsedFavoriteArray
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCells",for: indexPath) as! searchTableViewCell
        var dict = arrRes[indexPath.row]
        cell.indexNumber = indexPath.row
        cell.delegate = self
        cell.searchResultLabel?.text = dict["title"] as? String
        let urlString = dict["image_url"]
        webURL = dict["source_url"] as! String
        let url = URL(string: urlString as! String )
        var imageName = ""
        if self.isAddedOnFavorite(item: dict) == true{
            imageName = "heart outline filled"
        }
        else{
            imageName = "heart outline blank"
        }
        cell.favoriteBtn.setImage(UIImage(named: imageName), for: .normal)
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

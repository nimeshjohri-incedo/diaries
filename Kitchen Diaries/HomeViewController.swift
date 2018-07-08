import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SDWebImage
import GoogleMobileAds

protocol categoriesTableViewCellDelegate:AnyObject {
    func didSelectButton(indexNumber:Int?) -> Void
}

class categoriesTableViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var btnFavorite: UIButton!
    var indexNumber :Int?
    var isSelectedCell :Bool?
    var image_name = "heart outline blank"
    weak var delegate:categoriesTableViewCellDelegate?
    @IBAction func favoriteButton(_ sender: UIButton) {
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

var webURL = ""
var favoriteArray = [[String:AnyObject]]()
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable,categoriesTableViewCellDelegate, GADBannerViewDelegate {
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var tableArray = [String] ()
    var image_name = ""
    var globalSearch = ""
    var sortType = "t"
    var selectindex : Int?
    var adBannerView: GADBannerView?
    var selectedindex : NSMutableArray = NSMutableArray()
    
    func responseFromUser(searchTerm: String) {
        globalSearch = searchTerm
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511")
        
        return true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionLabelCell",for: indexPath) as! categoriesTableViewCell
            if((UserDefaults.standard.object(forKey: "Key")) != nil) {
                let returnValue = UserDefaults.standard.object(forKey: "Key") as! [[String:AnyObject]]
                let parsedFavoriteArray = Array(returnValue)
                favoriteArray = parsedFavoriteArray
            }
            var dict = arrRes[indexPath.row]
            cell.indexNumber = indexPath.row
            cell.delegate = self
            cell.headLabel?.text = dict["title"] as? String
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
            cell.btnFavorite.setImage(UIImage(named: imageName), for: .normal)
            if(url != nil) {
                cell.foodImage?.sd_setImage(with: url, placeholderImage:UIImage(named: "boardTextArea.png"))
            }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        HomeTiles.tableHeaderView?.frame = bannerView.frame
        HomeTiles.tableHeaderView = bannerView
        HomeTiles.tableFooterView?.frame = bannerView.frame
        HomeTiles.tableFooterView = bannerView
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
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
        apiDataFetch()
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView?.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        adBannerView?.delegate = self
        adBannerView?.rootViewController = self
        adBannerView?.load(GADRequest())
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
  
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SDWebImage

class favoritesTableViewCell: UITableViewCell {
    @IBOutlet weak var favoritesViewCell: UIView!
    @IBOutlet weak var favoritesImageArea: UIImageView!
    @IBOutlet weak var favoritesCellLabel: UILabel!
}
class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    @IBOutlet weak var favoritesTableView: UITableView!
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var tableArray = [String] ()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesTableCell",for: indexPath) as! favoritesTableViewCell
        var dict = arrRes[indexPath.row]
        cell.favoritesCellLabel?.text = dict["title"] as? String
        let urlString = dict["image_url"]
        webURL = dict["source_url"] as! String
        let url = URL(string: urlString as! String )
        if(url != nil) {
            cell.favoritesImageArea?.sd_setImage(with: url, placeholderImage:UIImage(named: "boardTextArea.png"))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "favoritesView", sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0;//Choose your custom row height
    }
    func apiDataFetch() {
        startAnimating(CGSize(width: 60, height: 60), message: "Serving.. Just a second")
        self.favoritesTableView!.register(favoritesTableViewCell.self, forCellReuseIdentifier: "favoritesTableViewCell")
        var apiURL = String()
        apiURL = "https://food2fork.com/api/search?key=db6356d5fea03017abb29532c24a4090&q="
        print(apiURL)
        Alamofire.request(apiURL).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["recipes"].arrayObject {
                    self.arrRes = resData as! [[String:AnyObject]]
                    //print(self.arrRes)
                }
                if self.arrRes.count > 0 {
                    self.favoritesTableView.reloadData()
                }
                self.stopAnimating()
            }
        }
        self.favoritesTableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        apiDataFetch()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

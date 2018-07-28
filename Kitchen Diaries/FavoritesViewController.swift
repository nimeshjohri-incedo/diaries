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
    var localTableArray = [[String:AnyObject]]()
    //var favoritesCount = 0;
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let returnValue = UserDefaults.standard.object(forKey: "Key") as! [[String:AnyObject]]
//        let parsedFavoriteArray = Array(returnValue)
//        localTableArray = parsedFavoriteArray
//        favoritesCount = parsedFavoriteArray.count
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesTableCell",for: indexPath) as! favoritesTableViewCell
        var dict = favoriteArray[indexPath.row]
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
        return favoriteArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "favoritesView", sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0;//Choose your custom row height
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if favoriteArray.isEmpty == false{
            self.favoritesTableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

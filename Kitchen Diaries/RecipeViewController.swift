import UIKit
import Firebase
import SwiftyJSON
import FirebaseStorage
import NVActivityIndicatorView

class userRecipesTableViewCell: UITableViewCell {
    @IBOutlet weak var userRecipesView: UIView!
    @IBOutlet weak var publisherHead: UILabel!
    @IBOutlet weak var recipeHead: UILabel!
    @IBOutlet weak var userRecipeImage: UIImageView!
}

class RecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    @IBOutlet weak var userRecipesTable: UITableView!
    
    var arrRes = [[String:AnyObject]]()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myRecipeCell",for: indexPath) as! userRecipesTableViewCell
        var dict = self.arrRes[indexPath.row]
        cell.recipeHead?.text = dict["title"] as? String
        cell.publisherHead?.text = dict["publisher"] as? String
        let urlString = dict["image_url"]
        //webURL = dict["source_url"] as! String
        let url = URL(string: urlString as! String )
        if(url != nil) {
            cell.userRecipeImage?.sd_setImage(with: url, placeholderImage:UIImage(named: "boardTextArea.png"))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrRes.count
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "favoritesView", sender: self)
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0;//Choose your custom row height
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        startAnimating(CGSize(width: 60, height: 60), message: "Serving..")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let objectArrayOfAllValues:Array = Array(value!.allValues)
            self.arrRes = objectArrayOfAllValues as! [[String:AnyObject]]
            self.userRecipesTable.reloadData()
            self.stopAnimating()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        userRecipesTable.delegate = self
        userRecipesTable.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

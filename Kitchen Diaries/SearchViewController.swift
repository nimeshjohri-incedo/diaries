import UIKit
import Speech
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SDWebImage
import GoogleMobileAds

protocol searchTableViewCellDelegate:AnyObject {
    func didSelectButton(indexNumber:Int?) -> Void
    func didSocialSelectButton(indexNumber:Int?) -> Void
}

class searchTableViewCell: UITableViewCell {
    @IBOutlet weak var searchCellView: UIView!
    @IBOutlet weak var searchResultImage: UIImageView!
    @IBOutlet weak var searchResultLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    @IBAction func socialSharingAction(_ sender: UIButton) {
        if self.delegate != nil {
            self.delegate?.didSocialSelectButton(indexNumber: self.indexNumber)
        }
    }
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

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, searchTableViewCellDelegate, SFSpeechRecognizerDelegate {
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var tableArray = [String] ()
    var globalSearch = ""
    var sortType = "t"
    var scrollStatus = 1
    var loadingData = false
    var listeningToUser = "recognizing"
    let speechEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    let speechRequest = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    @IBOutlet weak var cellTableView: UITableView!
    @IBOutlet weak var searchTerm: UISearchBar!
 
    @IBAction func voiceSearchButton(_ sender: UIButton) {
        switch listeningToUser {
        case "recognizing":
            self.searchTerm.text = ""
            self.view.endEditing(true)
            startAnimating(CGSize(width: 60, height: 60), message: "Listening..")
            tapAndRecognizeVoice()
        default:
            break
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        globalSearch = (searchTerm?.text)!
        apiDataFetch(pageOffset: scrollStatus)
        // cellTableView.reloadData()
        self.view.endEditing(true)
    }
    func tapAndRecognizeVoice() {
        let inputNode = speechEngine.inputNode
       // let node = speechEngine.inputNode
        let speechFormat = inputNode.inputFormat(forBus: 0) //AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: speechFormat) { buffer, _ in
            self.speechRequest.append(buffer)
        }
        self.speechEngine.prepare()
        do {
            try speechEngine.start()
        } catch {
            return print("Error\(error)")
        }
        guard let voiceRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !voiceRecognizer.isAvailable {
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: speechRequest, resultHandler: { result, error in
            if let result = result {
                print(result)
                let finalString = result.bestTranscription.formattedString
                self.searchTerm.text = finalString
                self.globalSearch = (finalString)
                //self.stopAnimating()
                self.cellTableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.cancelRecording()
                    self.apiDataFetch(pageOffset: self.scrollStatus)
                }
            } else if let error = error {
                print(error)
                self.cancelRecording()
            }
        })
    }
    
    func cancelRecording() {
        speechRequest.endAudio()
        speechEngine.stop()
        speechEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
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
    var activityViewController:UIActivityViewController?
    func didSocialSelectButton(indexNumber:Int?) -> Void{
        let selectedCell = arrRes[indexNumber!]
        let linkToBeShared = selectedCell["source_url"] as! String
        print(linkToBeShared)
        activityViewController = UIActivityViewController(
            activityItems: [linkToBeShared as NSString],
            applicationActivities: nil)
        present(activityViewController!, animated: true, completion: nil)
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
        if(arrRes.count > 0) {
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
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrRes.count > 0 {
            print(arrRes.count)
            return arrRes.count
        } else {
            arrRes.removeAll()
            //cellTableView.reloadData()
            return 0
        }
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
        let charactersAllowed = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)
        let encodedString = globalSearch.addingPercentEncoding(withAllowedCharacters: charactersAllowed)!
        apiURL = "https://food2fork.com/api/search?key=db6356d5fea03017abb29532c24a4090&q=\(encodedString)&page=\(pageOffset)"
        print(apiURL)
        Alamofire.request(apiURL).responseJSON { (responseData) -> Void in
            self.arrRes.removeAll()
            if(responseData.result.isSuccess) {
                self.scrollStatus = 1
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    if let resData = swiftyJsonVar["recipes"].arrayObject {
                        if(self.loadingData == true) {
                            self.arrRes.append(contentsOf: resData as! [[String:AnyObject]])
                        } else {
                            self.arrRes = resData as! [[String:AnyObject]]
                        }
                    }
                    if self.arrRes.count > 0 {
                        self.cellTableView.reloadData()
                    }
                    self.stopAnimating()
                } else {
                    self.cellTableView.reloadData()
                }
            } else if(responseData.result.isFailure) {
                self.stopAnimating()
                self.cellTableView.reloadData()
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

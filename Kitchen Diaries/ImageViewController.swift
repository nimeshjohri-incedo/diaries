import UIKit
import Firebase
import SwiftMessages
import FirebaseStorage

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let uuid = UUID().uuidString
    var downloadedURL = URL(string: "")
    var replacedURL = "" as Any
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var prepTime: UITextField!
    @IBOutlet weak var servingsCount: UITextField!
    @IBOutlet weak var publisherName: UITextField!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var ingredientsText: UITextView!
    @IBOutlet weak var directionsText: UITextView!
    @IBAction func createRecipe(_ sender: UIButton) {
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .center
        successConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: "", body: "Added to your recipes")
        success.button?.isHidden = true
        if(downloadedURL == nil) {
            replacedURL = " "
        } else {
            replacedURL = downloadedURL!.absoluteString
        }
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child(uuid).setValue(["title": recipeName.text!,"publisher": publisherName.text!, "prepTime": prepTime.text!, "servingsCount": servingsCount.text!, "ingredientsText": ingredientsText.text!, "directionsText": directionsText.text!, "image_url":replacedURL, "recipeId":uuid])
        SwiftMessages.show(config: successConfig, view: success)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "moreOptions") as? UITableViewController
        vc?.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func imageUpload(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.tapRecognized))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    @objc func tapRecognized() {
        view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let storage = Storage.storage()
        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        let imageData = UIImagePNGRepresentation(image)!
        let photosRef = storage.reference()
            let photoRef = photosRef.child(uuid)

        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        photoRef.putData(imageData, metadata: nil,completion:{(metadata,error) in
            self.recipeImage.image = image
            photoRef.downloadURL { (url, error) in
                self.downloadedURL = url
                print("url")
                print(self.downloadedURL!)
            }
        })
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

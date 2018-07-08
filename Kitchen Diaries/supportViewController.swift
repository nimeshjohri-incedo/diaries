//
//  supportViewController.swift
//  Kitchen Diaries
//
//  Created by Nimesh Johri on 6/8/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit
import MessageUI

class supportViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    let systemVersion = UIDevice.current.systemVersion
    let model = UIDevice.current.model
    @IBOutlet weak var feedbackViews: UITextView!
    @IBOutlet weak var senderName: UITextField!
    @IBAction func feedbackSubmit(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let fullSystemVersion = "Device OS Version \(systemVersion)"
        let modelInfo = "Device Type \(model)"
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["nimeshjohri2009@gmail.com"])
        mailComposerVC.setSubject("Kitchen Diaries Feedback from \(senderName.text ?? "no name")")
        mailComposerVC.setMessageBody("Hi, \n\n"+feedbackViews.text+"\n\n"+fullSystemVersion+"\n\n"+modelInfo, isHTML: false)
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sendMailErrorAlert, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        feedbackViews.delegate = self
        feedbackViews.text = "Please provide us your feedback.."
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        feedbackViews.text = " "
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

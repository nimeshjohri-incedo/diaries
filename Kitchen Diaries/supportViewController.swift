//
//  supportViewController.swift
//  Kitchen Diaries
//
//  Created by Nimesh Johri on 6/8/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit

class supportViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var feedbackViews: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        feedbackViews.text = "Please provide us your feedback.."
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        feedbackViews.text = " "
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

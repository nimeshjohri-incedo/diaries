//
//  WebViewController.swift
//  Kitchen Diaries
//
//  Created by Nimesh Johri on 5/29/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit
import WebKit
import NVActivityIndicatorView

class WebViewController: UIViewController, WKNavigationDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var webView: WKWebView!
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        title = webView.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startAnimating(CGSize(width: 60, height: 60), message: "Serving..")
        let url = URL(string: webURL)!
        print(url)
        webView.load(URLRequest(url: url))
        navigationController?.isToolbarHidden = false
        let deadlineTime = DispatchTime.now() + .seconds(7)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.stopAnimating()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
}



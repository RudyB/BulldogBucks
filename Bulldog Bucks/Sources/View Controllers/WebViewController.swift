//
//  WebViewController.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 12/12/16.
//
//

import UIKit

typealias WebViewAction = ((WebViewController) -> Void)

class WebViewController: UIViewController {

    public static let storyboardIdentifier: String = "webView"
    
    var url: String!
    
	@IBOutlet weak var webView: UIWebView!
	@IBOutlet weak var backBarButton: UIBarButtonItem!
	@IBOutlet weak var forwardBarButton: UIBarButtonItem!
	@IBOutlet weak var closeNavButton: UIBarButtonItem!
	@IBOutlet weak var refreshNavButton: UIBarButtonItem!
	
	
    override func viewWillAppear(_ animated: Bool) {
		closeNavButton.action = #selector(closeWebView)
        refreshNavButton.action = #selector(reloadWebPage)
        backBarButton.action = #selector(goBack)
        forwardBarButton.action = #selector(goForward)
        self.webView.delegate = self
        loadWebView()
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
 
    
    func loadWebView() {
        guard
            let url = URL(string: url)
        else { return }
        print(url)
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    
    @objc func reloadWebPage() {
        webView.reload()
    }
   
    @objc func goBack() {
        webView.goBack()
    }
    
    @objc func goForward() {
        webView.goForward()
    }
    
    @objc func closeWebView() {
        dismiss(animated: true, completion: nil)
    }

}

extension WebViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView.canGoBack {
            backBarButton.isEnabled = true
        } else {
            backBarButton.isEnabled = false
        }
        
        if webView.canGoForward {
            forwardBarButton.isEnabled = true
        } else {
            forwardBarButton.isEnabled = false
        }
    }
    
}

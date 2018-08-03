//
//  WebViewController.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 12/12/16.
//
//

import UIKit
import MBProgressHUD

typealias WebViewAction = ((WebViewController) -> Void)

class WebViewController: UIViewController {

    public static let storyboardIdentifier: String = "webView"

    var url: String = "https://zagweb.gonzaga.edu/prod/hwgwcard.transactions"

    var logoutFunc: WebViewAction?

	@IBOutlet weak var webView: UIWebView!
	@IBOutlet weak var backBarButton: UIBarButtonItem!
	@IBOutlet weak var forwardBarButton: UIBarButtonItem!
	@IBOutlet weak var closeNavButton: UIBarButtonItem!
	@IBOutlet weak var refreshNavButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navbar: UINavigationBar!

    override func viewWillAppear(_ animated: Bool) {
		closeNavButton.action = #selector(closeWebView)
        refreshNavButton.action = #selector(reloadWebPage)
        backBarButton.action = #selector(goBack)
        forwardBarButton.action = #selector(goForward)
        self.webView.delegate = self

        let bounds = navbar.bounds
        let height: CGFloat = 50 //whatever height you want to add to the existing height
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        navigationController?.navigationBar.barStyle = .default
        showLoadingHUD()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.barStyle = .blackOpaque
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navItem.title = title
    }

    func loadWebView() {
        guard
            let url = URL(string: url)
        else { return }
        print(url)
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }

    /// Displays a Loading View
    fileprivate func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Loading..."
        hud.hide(animated: true, afterDelay: 10)
    }

    /// Hides the Loading View
    fileprivate func hideLoadingHUD() {
        MBProgressHUD.hide(for: view, animated: true)
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
        logoutFunc?(self)
        dismiss(animated: true, completion: nil)
    }

}

extension WebViewController: UIWebViewDelegate {

    /// Starts animating the activity indicator when webView is loading
    func webViewDidStartLoad(_ webView: UIWebView) {
        showLoadingHUD()
    }

    /// Stops animating the activity indicator when webView is done loading
    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.async {
            self.hideLoadingHUD()
            self.backBarButton.isEnabled = webView.canGoBack
            self.forwardBarButton.isEnabled = webView.canGoForward
        }

    }

}

//
//  ViewController.swift
//  Bulldog Bucks Meter
//
//  Created by Rudy Bermudez on 9/26/16.
//
//

import UIKit
import OnePasswordExtension

protocol LoginViewControllerDelegate {
	func didLoginSuccessfully()
}

class LoginViewController: UIViewController, UIViewControllerTransitioningDelegate {

	// MARK: - IBOutlets
	@IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var userIDTextField: UITextField!
	@IBOutlet weak var userPinTextField: UITextField!
	@IBOutlet weak var loginButton: TKTransitionSubmitButton!
	@IBOutlet weak var onepasswordSigninButton: UIButton!

	public static let storyboardIdentifier = "LoginViewController"

	// MARK: - Properties
    private let keychain = BDBKeychain.phoneKeychain

	var delegate: AuthenticationStateDelegate?

	lazy var notificationCenter: NotificationCenter = {
		return NotificationCenter.default
	}()

	// MARK: - UIViewController
	override var prefersStatusBarHidden: Bool {
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNotificationCenter()
        setupGestureRecognizer()
        onepasswordSigninButton.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    /// Action will fill the `userIDTextField` & `userPinTextField` textfields with credentials from 1Password
	@IBAction func findLoginFrom1Password() {
		OnePasswordExtension.shared().findLogin(forURLString: "https://zagweb.gonzaga.edu", for: self, sender: self) { (loginDictionary, error) in

            if let error = error {
                if !error.isCancelledError {
                    NSLog("Error invoking 1Password App Extension for find login: %s", error.localizedDescription)
                }
                return
            }

			guard let loginDictionary = loginDictionary,
                loginDictionary.count != 0,
                let username = loginDictionary[AppExtensionUsernameKey] as? String,
                let password = loginDictionary[AppExtensionPasswordKey] as? String
                else {
				NSLog("Failed to unwrap LoginDictionary")
				return
			}
			// Fill Credential Fields
            self.userIDTextField.text = username
            self.userPinTextField.text = password

            // Call Login Action
            self.loginAction(self)

		}
	}

	/**
     Login Action
     
     Checks if there is internet connection, checks to make sure fields are not empty, then attempts to authenticate by calling `self.login()`
     
     - Parameter sender: The instance that sends the action
     */

	@IBAction func loginAction(_ sender: Any) {
        if isConnectedToNetwork() {
            guard let userIDTextFieldText = userIDTextField.text, let userPinTextFieldText = userPinTextField.text else {
                return
            }
            if userIDTextFieldText.isEmpty || userPinTextFieldText.isEmpty {
                showAlert(target: self, title: "Error", message: "Student ID and PIN cannot be left empty")
                return
            } else {
                self.loginButton.startLoadingAnimation()
                login(studentID: userIDTextFieldText, PIN: userPinTextFieldText)
            }
        } else {
            showAlert(target: self, title: "No Active Connection to Internet")
        }
	}

    /**
     Login Action
     
     Checks if there is internet connection, then attempts to authenticate by calling `self.checkCredentials()`
     
     */
    private func login(studentID: String, PIN: String) {
        if isConnectedToNetwork() {
            checkCredentials(withStudentID: studentID, withPIN: PIN)
        } else {
            showAlert(target: self, title: "No Active Connection to Internet")
        }
    }

    // MARK: - UI Helper Functions

    /**
     Adds NotificationCenter Observers for when the Keyboard Appears and Disappears. 
     - When keyboard appears, `self.keyboardWillAppear()` is called
     - When keyboard disappers, `self.keyboardWillDisappear()` is called
     */
    private func setupNotificationCenter() {
        // Notification Center Observers
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillDisappear(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    /**
     Adds a UITapGestureRecognizer to see if the user taps outside of the text field.
     
     If a tap is recognized, `UIView.endEditing` is called
    */
    private func setupGestureRecognizer() {
        // Keyboard Dismissal
        let tapper = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }

    /**
     Animation that moves the `loginButtonBottomConstraint` 20 points higher than the top of the keyboard frame.
     
     Called when notification is posted for `NSNotification.Name.UIKeyboardWillShow`
     */
    @objc
	func keyboardWillAppear(notification: NSNotification) {
		if let userInfoDict = notification.userInfo, let keyboardFrameValue = userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue {
			let keyboardFrame = keyboardFrameValue.cgRectValue

			UIView.animate(withDuration: 0.8) {
				self.loginButtonBottomConstraint.constant = keyboardFrame.size.height
					+ 20
				self.view.layoutIfNeeded()
			}

		}
	}

    /**
     Animation that moves the loginButtonBottomConstraint to it's original position.
     
     Called when notification is posted for `NSNotification.Name.UIKeyboardDidHide`
     */
    @objc
	func keyboardWillDisappear(notification: NSNotification) {
		UIView.animate(withDuration: 0.5) {
			self.loginButtonBottomConstraint.constant = 202.0
			self.view.layoutIfNeeded()
		}
	}

    /**
     Checks to see if the authentication to Zagweb is successful. If successful, `delegate?.didLoginSuccessfully()` is called and transitions to `ViewController`. If fails, shows alert.
     
     - Parameters:
        - withStudentID: The student ID of the user as a `String`
        - withPIN: The PIN of the user as a `String`
     */
	private func checkCredentials(withStudentID: String, withPIN: String) {
		ZagwebClient.authenticate(withStudentID: withStudentID, withPIN: withPIN).then { (_) -> Void in

            let success = self.keychain.addCredentials(studentID: withStudentID, PIN: withPIN)
            if success {
                self.loginButton.startFinishAnimation {
                    self.userIDTextField.text = ""
                    self.userPinTextField.text = ""
                    self.delegate?.didLoginSuccessfully()
                }
            } else {
                throw KeychainError.DidNotSaveCredentials
            }

            print("logged in")

		}.catch { (error) in
            print(error)
			if let error = error as? ClientError {
                switch error {
                case .invalidCredentials:
                    self.loginButton.returnToOriginalState()
                    showAlert(target: self, title: error.domain())
                default:
                    self.loginButton.returnToOriginalState()
                    showAlert(target: self, title: "Networking Error", message: error.domain())
                }

			}
            _ = self.keychain.deleteCredentials()
		}
	}

	// MARK: - UIViewControllerTransitioningDelegate
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let fadeInAnimator = TKFadeInAnimator()
		return fadeInAnimator
	}

	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return nil
	}

}

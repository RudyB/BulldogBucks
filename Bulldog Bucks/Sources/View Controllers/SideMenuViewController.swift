//
//  SideMenuViewController.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 3/29/18.
//

import UIKit
import MBProgressHUD

enum SideMenuOption: Int {
    case transactions
    case locations
	case freezeZagcard
    case viewInBrowser
	case logout

	init?(atIndex: Int) {
		if let instance = SideMenuOption(rawValue: atIndex) {
			self = instance
		} else {
			return nil
		}
	}

	func toCell() -> (image: UIImage, label: String) {
		switch self {
        case .transactions:
            return (#imageLiteral(resourceName: "transactions"), "Transactions")
        case .locations:
            return (#imageLiteral(resourceName: "location-black"), "Locations")
		case .freezeZagcard:
            guard let state = SideMenuDataManager.shared.cardState else { return (#imageLiteral(resourceName: "pause"), "Freeze Zagcard") }
            switch state {
            case .active: return (#imageLiteral(resourceName: "pause"), "Freeze Zagcard")
            case .frozen: return(#imageLiteral(resourceName: "resume"), "Activate Zagcard")
            }
        case .viewInBrowser:
            return (#imageLiteral(resourceName: "openInBrowser-black"), "View in Browser")
		case .logout:
			return (#imageLiteral(resourceName: "logoutBlack"), "Logout")
		}
	}
}

class SideMenuDataManager {

    static var shared: SideMenuDataManager = SideMenuDataManager()
    var cardState: CardState?
}

class SideMenuViewController: UIViewController {

	public static let storyboardIdentifier = "sideMenu"

	@IBOutlet weak var tableview: UITableView!

	var delegate: AuthenticationStateDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableview.dataSource = self
		self.tableview.delegate = self
		self.tableview.register(UINib(nibName: SideMenuTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: SideMenuTableViewCell.cellIdentifier)
		// Sets the navigation Bar hidden for the SideMenu and SideMenu Only
		self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func logout() {

        let cookieStorage: HTTPCookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: URL(string: "zagweb.gonzaga.edu")!)

        if let cookies = cookies {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie as HTTPCookie)
            }
        }
        ZagwebDataSetManager.purgeDataSets()
        let logoutSuccess = BDBKeychain.phoneKeychain.deleteCredentials()
        if logoutSuccess {
            dismiss(animated: true, completion: nil)
            delegate?.didLogoutSuccessfully()
        } else {
            // This should never happen, but it is good to handle the error just in case.
            showAlert(target: self, title: "Houston we have a problem!", message: "Logout failed. Please try again.")
        }
    }

    func presentTransactionsVC () {
        let transactionsVC = storyboard?.instantiateViewController(withIdentifier: TransactionViewController.storyboardIdentifier) as! TransactionViewController

        navigationController?.show(transactionsVC, sender: self)
    }

    func presentLocationsVC() {

        let vc = storyboard?.instantiateViewController(withIdentifier: LocationResultsViewController.storyboardIdentifier) as! LocationResultsViewController

        navigationController?.show(vc, sender: self)
    }

    func updateCardState(for cell: SideMenuTableViewCell) {
        showLoadingHUD()
        guard let state = SideMenuDataManager.shared.cardState else { return }
        let toggledState: CardState = {
            if case CardState.active = state {
                return CardState.frozen
            } else {
                return CardState.active
            }
        }()

        userChangedZagcardState(cardState: toggledState) { (success) in
            self.hideLoadingHUD()
            guard success else { return }
            SideMenuDataManager.shared.cardState = toggledState
            switch toggledState {
            case .active:
                cell.label.text = "Freeze Zagcard"
                cell.optionImage.image = #imageLiteral(resourceName: "pause")
            case .frozen:
                cell.label.text = "Enable Zagcard"
                cell.optionImage.image = #imageLiteral(resourceName: "resume")
            }
        }

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

    func userChangedZagcardState(cardState: CardState, onCompletion: @escaping (Bool) -> Void ) {
        guard let credentials = BDBKeychain.phoneKeychain.getCredentials() else {
            onCompletion(false)
            return
        }
        ZagwebClient.freezeUnfreezeZagcard(withStudentID: credentials.studentID, withPIN: credentials.PIN, desiredCardState: cardState).then { () -> Void in
            onCompletion(true)
            return
            }.catch { (_) in
                onCompletion(false)
                return
        }
    }

    func openInBrowser() {
        guard let credential = BDBKeychain.phoneKeychain.getCredentials() else { return }

        ZagwebClient.authenticate(withStudentID: credential.studentID, withPIN: credential.PIN).then { (_) -> Void in
             let webVC = self.storyboard?.instantiateViewController(withIdentifier: WebViewController.storyboardIdentifier) as! WebViewController
            webVC.logoutFunc = { webView in
                _ = ZagwebClient.logout()
            }
            self.present(webVC, animated: true, completion: nil)
            }.catch { (error) in
                print(error)
        }

    }

}

extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let currentOption = SideMenuOption(atIndex: indexPath.row)?.toCell()
		let cell = tableview.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.cellIdentifier, for: indexPath) as! SideMenuTableViewCell

		cell.optionImage.image = currentOption?.image
		cell.label.text = currentOption?.label
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == SideMenuOption.transactions.rawValue {
            presentTransactionsVC()
        } else if indexPath.row == SideMenuOption.freezeZagcard.rawValue {
            updateCardState(for: tableView.cellForRow(at: indexPath) as! SideMenuTableViewCell)
        } else if indexPath.row == SideMenuOption.locations.rawValue {
            presentLocationsVC()
        } else if indexPath.row == SideMenuOption.viewInBrowser.rawValue {
            openInBrowser()
        } else if indexPath.row == SideMenuOption.logout.rawValue {
			logout()
		}
	}

}

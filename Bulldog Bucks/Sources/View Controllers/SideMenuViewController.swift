//
//  SideMenuViewController.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 3/29/18.
//

import UIKit

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
            return (#imageLiteral(resourceName: "transaction"), "Transactions")
        case .locations:
            return (#imageLiteral(resourceName: "location-black"), "Locations")
		case .freezeZagcard:
			return (#imageLiteral(resourceName: "pause"), "Freeze Zagcard")
        case .viewInBrowser:
            return (#imageLiteral(resourceName: "openInBrowser-black"), "View in Browser")
		case .logout:
			return (#imageLiteral(resourceName: "logoutBlack"), "Logout")
		}
	}
}

class SideMenuViewController: UIViewController {

	public static let storyboardIdentifier = "sideMenu"
	
	@IBOutlet weak var tableview: UITableView!
	
	var delegate: AuthenticationStateDelegate?
	
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
    
    func toggleFreezeZagcard() {
        
    }
    
    func openInBrowser() {
        
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
        }else if indexPath.row == SideMenuOption.freezeZagcard.rawValue {
            toggleFreezeZagcard()
        } else if indexPath.row == SideMenuOption.locations.rawValue {
            presentLocationsVC()
        } else if indexPath.row == SideMenuOption.viewInBrowser.rawValue {
            openInBrowser()
        } else if indexPath.row == SideMenuOption.logout.rawValue {
			logout()
		}
	}
	
}

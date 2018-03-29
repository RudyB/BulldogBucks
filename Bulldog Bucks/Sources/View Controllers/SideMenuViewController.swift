//
//  SideMenuViewController.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 3/29/18.
//

import UIKit

enum SideMenuOption: Int {
    case locations
	case accountSettings
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
        case .locations:
            return (#imageLiteral(resourceName: "location-black"), "Locations")
		case .accountSettings:
			return (#imageLiteral(resourceName: "pause"), "Freeze Zagcard")
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
	
	func presentAccountSettings() {
        // FIXME: RudyB 3/29
//        let vc = storyboard?.instantiateViewController(withIdentifier: AccountSettingsViewController.storyboardIdentifier) as! AccountSettingsViewController
//        self.navigationController?.pushViewController(vc, animated: false)
	}

}

extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let currentOption = SideMenuOption(atIndex: indexPath.row)?.toCell()
		let cell = tableview.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.cellIdentifier, for: indexPath) as! SideMenuTableViewCell
		
		cell.optionImage.image = currentOption?.image
		cell.label.text = currentOption?.label
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == SideMenuOption.accountSettings.rawValue {
			presentAccountSettings()
		}
		else if indexPath.row == SideMenuOption.logout.rawValue {
			logout()
		}
	}
	
}

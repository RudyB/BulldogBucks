//
//  MainPageViewController.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 9/3/17.
//
//

import UIKit
import DGElasticPullToRefresh
import MBProgressHUD


class TransactionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
	@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    public static let storyboardIdentifier = "TransactionViewControllerID"
    
    var delegate: AuthenticationStateDelegate?
    
    lazy var client: ZagwebClient = {
        return ZagwebClient()
    }()
    
    /// Last Day of the Current of Semester in UNIX time
    /// This is used to calculate the amount of money remaining per week
    /// Updated for the Fall Semester of the 2017 - 2018 Academic School year
    let lastDayOfSemester = Date(timeIntervalSince1970: 1513296000)
    
    
    var transactions: [Transaction]?
    var bulldogBuckBalance: String?
    var swipesRemaining: String?
    var cardState: CardState?
    
    var sections = Dictionary<Date, Array<Transaction>>()
    
    var sortedSections = [Date]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPullToRefresh()
        showLoadingHUD()
        // Configure Delegates
        scrollView.delegate = self
        tableView.dataSource = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        pageControl.numberOfPages = collectionView.numberOfSections
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        getData()
    }
    
    deinit {
        scrollView.dg_removePullToRefresh()
    }
    
    func setupPullToRefresh() {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        self.scrollView.dg_addPullToRefreshWithActionHandler({
            self.getData()
        }, loadingView: loadingView)
        
        self.scrollView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        scrollView.dg_setPullToRefreshBackgroundColor(self.view.backgroundColor!)
    }
    
    func sortTransactions() {
        
        sections = [:]
        sortedSections = []
        
        guard let transactions = transactions else {
            return
        }
        
        for transaction in transactions {
            
            if sections.index(forKey: transaction.dateForSorting) == nil {
                sections[transaction.dateForSorting] = [transaction]
            } else {
                sections[transaction.dateForSorting]?.append(transaction)
            }
        }
        
        sortedSections = sections.keys.sorted().reversed()
    }
    
    func getData() {
        
        guard let credentials = BDBKeychain.phoneKeychain.getCredentials() else {
            self.logout()
            return
        }
        transactions = nil
        bulldogBuckBalance = nil
        swipesRemaining = nil
        cardState = nil
        
        client.getBulldogBucks(withStudentID: credentials.studentID, withPIN: credentials.PIN)
            .then { (amount, transactions, cardState , swipesRemaining) -> Void in
                self.transactions = transactions
                self.bulldogBuckBalance = amount
                self.swipesRemaining = swipesRemaining
                self.cardState = cardState
                
                self.sortTransactions()
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.hideLoadingHUD()
            }.catch { (error) in
                print(error.localizedDescription)
                self.hideLoadingHUD()
                if let error = error as? ClientError {
                    switch error {
                    case .invalidCredentials:
                
                        let action = UIAlertAction(title: "Logout", style: .default){ (_) in
                            self.logout()
                        }
                        showAlert(target: self, title: "Hold Up!", message: "It looks like you have changed your password. Logout and Try Again", actionList: [action])
                    default:
                        showAlert(target: self, title: "Error", message: error.domain())
                    }
                } else {
                    showAlert(target: self, title: "Error", message: error.localizedDescription)
                }
        }
        
    }
    
    func logout() -> () {
        
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
    
    // MARK : - MBProgressHUD Methods
    
    /// Displays a Loading View
    fileprivate func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading..."
    }
    
    /// Hides the Loading View
    fileprivate func hideLoadingHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
        self.scrollView.dg_stopLoading()
    }
    
    
}


extension TransactionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let bulldogBuckBalance = bulldogBuckBalance, let swipesRemaining = swipesRemaining, let cardState = cardState else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
        }
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
            cell.titleLabel.text = "Bulldog Bucks Remaining"
            cell.amountLabel.text = "$\(bulldogBuckBalance)"
            
            let weeksUntilEndOfSchoolYear = NSDate().weeks(to: self.lastDayOfSemester)
            if weeksUntilEndOfSchoolYear > 0 {
                let dailyBalance = Double(bulldogBuckBalance)! / Double(weeksUntilEndOfSchoolYear)
                cell.weeklyLabel.text = String(format: "Budget $%.2f per week", dailyBalance)
            }
            return cell
            
        case 1:
            guard let swipesRemainingAsInt = Int(swipesRemaining) else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenericCollectionViewCell.reuseIdentifier, for: indexPath) as! GenericCollectionViewCell
                cell.amountLabel.text = swipesRemaining
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
            cell.titleLabel.text = "Swipes Remaining"
            cell.amountLabel.text = swipesRemaining
            
            
            let weeksUntilEndOfSchoolYear = NSDate().weeks(to: self.lastDayOfSemester)
            if weeksUntilEndOfSchoolYear > 0 {
                let weeklyBalance = swipesRemainingAsInt / weeksUntilEndOfSchoolYear
                cell.weeklyLabel.text = "Budget \(weeklyBalance) per week"
            }
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier, for: indexPath) as! ButtonCollectionViewCell
            
            cell.logoutAction = logout
            
            cell.toggleCardStatusAction = { (cardState, onCompetion) -> Void in
                
                guard let credentials = BDBKeychain.phoneKeychain.getCredentials() else {
                    onCompetion(false)
                    return
                }
                self.client.freezeUnfreezeZagcard(withStudentID: credentials.studentID, withPIN: credentials.PIN, desiredCardState: cardState).then{ () -> () in
                    onCompetion(true)
                    return
                    }.catch { (error) in
                        onCompetion(false)
                        return
                }
                
            }
            
            switch cardState {
            case .active:
                cell.statusLabel.text = "ZAGCARD Active"
                cell.switchOutlet.isOn = true
            case .frozen:
                cell.statusLabel.text = "ZAGCARD Frozen"
                cell.switchOutlet.isOn = false
            }
            
            return cell
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    
}

extension TransactionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let curSection = sections[sortedSections[section]] else {
            return 0
        }
        return curSection.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let tableSection = sections[sortedSections[indexPath.section]] else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.storyboardIdentifier) as! TransactionTableViewCell
        
        let transaction = tableSection[indexPath.row]
        
        cell.venueLabel.text = transaction.venue
        
        cell.amountLabel.text = transaction.prettyAmount
        
        if transaction.type == .deposit {
            cell.amountLabel.textColor = UIColor(red: 106.0/255.0, green: 148.0/255.0, blue: 88.0/255.0, alpha: 1.0)
        } else {
            cell.amountLabel.textColor = UIColor.gray
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return sections[sortedSections[section]]?.first?.sectionHeaderDate
    }
}

extension TransactionViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.collectionView {
            // Implements better paging
            let pageWidth = scrollView.frame.width
            let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
            self.pageControl.currentPage = currentPage
        } else {
            // Make it so the user can only pull down, not up
            if (scrollView.contentOffset.y > 0) {
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                scrollView.bounces = false
            }
            
            if (scrollView.contentOffset.y == 0){
                scrollView.bounces = true
            }
            else {
                scrollView.bounces = true
            }
        }
        
    }
}

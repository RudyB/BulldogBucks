//
//  MainPageViewController.swift
//  Bulldog Bucks
//
//  Created by Rudy Bermudez on 9/3/17.
//
//

import UIKit

class TransactionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	@IBOutlet weak var pageControl: UIPageControl!
    
    
    public static let storyboardIdentifier = "TransactionViewControllerID"
    
    var delegate: AuthenticationStateDelegate?
    
    lazy var client: ZagwebClient = {
        return ZagwebClient()
    }()
    
    
    var transactions: [Transaction]?
    var bulldogBuckBalance: String?
    var swipesRemaining: String?
    
    var sections = Dictionary<Date, Array<Transaction>>()
    
    var sortedSections = [Date]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
		collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        getData()
    }
    
    func sortTransactions() {
        
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
            return
        }
        client.getBulldogBucks(withStudentID: credentials.studentID, withPIN: credentials.PIN)
            .then { (amount, transactions, cardState , swipesRemaining) -> Void in
                self.transactions = transactions
				self.bulldogBuckBalance = amount
                self.swipesRemaining = swipesRemaining
                
                self.sortTransactions()
                self.tableView.reloadData()
                self.collectionView.reloadData()
        }.catch { (error) in
            print(error.localizedDescription)
        }
    }
    
    
}


extension TransactionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let bulldogBuckBalance = bulldogBuckBalance, let swipesRemaining = swipesRemaining else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
        }
        
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
            cell.amountLabel.text = "$\(bulldogBuckBalance)"
            cell.titleLabel.text = "Bulldog Bucks Remaining"
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
            cell.amountLabel.text = swipesRemaining
            cell.titleLabel.text = "Swipes Remaining"
            return cell
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: DetailCollectionViewCell.reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.section
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

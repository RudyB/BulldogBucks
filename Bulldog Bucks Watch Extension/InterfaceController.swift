//
//  InterfaceController.swift
//  Bulldog Buck Balance Extension
//
//  Created by Rudy Bermudez on 3/11/17.
//
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

	@IBOutlet var headerLabel: WKInterfaceLabel!
	@IBOutlet var amountLabel: WKInterfaceLabel!
	@IBOutlet var swipesLabel: WKInterfaceLabel!
	@IBOutlet var errorLabel: WKInterfaceLabel!
	@IBOutlet var footerLabel: WKInterfaceLabel!
    @IBOutlet var loadingGroup: WKInterfaceGroup!
	@IBOutlet var detailGroup: WKInterfaceGroup!
	@IBOutlet var errorGroup: WKInterfaceGroup!

	@IBAction func reloadButton() {
		updateDisplay()
	}

    /// `String` constant for `NSNotification.Name() for when the user logs out of the application`
    public static let UserLoggedOutNotification = "UserLoggedOut"

    /// `String` constant for `NSNotification.Name() for when the user logs into the application`
    public static let UserLoggedInNotificaiton = "UserLoggedIn"

	let keychain = BDBKeychain.watchKeychain

    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Configure interface objects here.
		setupNotificationCenter()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimeOfLastUpdate), userInfo: nil, repeats: true)
    }

    override func didAppear() {

        // Check to see if there is a balance stored in memory, if it cannot be found, update the display with new data

        guard let lastBalance = ZagwebDataSetManager.dataSets.last else {
            updateDisplay()
            return
        }

        // Check to see if it has been 30 minutes from the last update,
        if NSDate().minutes(fromDate: lastBalance.date as NSDate) > 30 {
            // If it has been, then update
            updateDisplay()
        } else {
            // If not, update the label with the last balance
            swipesLabel.setText("\(lastBalance.swipesRemaining) Swipes")
            amountLabel.setText(lastBalance.bucksRemaining.prettyBalance)
            self.detailGroup.setHidden(false)
        }
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func updateDisplay() {
        DispatchQueue.main.async {
            self.errorGroup.setHidden(true)
            self.detailGroup.setHidden(true)
            self.loadingGroup.setHidden(false)
            if let credentials = self.keychain.getCredentials() {

                ZagwebClient.getBulldogBucks(withStudentID: credentials.studentID, withPIN: credentials.PIN).then { (amount, _, _, swipes) -> Void in

                    self.amountLabel.setText(amount.prettyBalance)
					self.swipesLabel.setText("\(swipes) Swipes")
                    let date = NSDate()

                    let newDataSet = ZagwebDataSet(bucksRemaining: amount, swipesRemaining: swipes, date: date as Date)
                    ZagwebDataSetManager.add(dataSet: newDataSet)

                    self.footerLabel.setText("Updated: \(date.timeAgoInWords)")
                    self.loadingGroup.setHidden(true)
                    self.detailGroup.setHidden(false)
                    self.updateComplication()
                    }.catch { (error) in
                        NSLog(error.localizedDescription)
                        self.showError(msg: "Trouble Getting Data.\n\nForce touch to try again.")
                    }

            } else {
                self.showError()
            }
        }
    }

    func updateComplication() {
        let complicationController = ComplicationController()
        complicationController.reloadOrExtendData()
    }

    func showError(msg: String = "Open App to Update") {
        self.loadingGroup.setHidden(true)
        self.detailGroup.setHidden(true)
        self.errorGroup.setHidden(false)
        errorLabel.setText(msg)
    }

    @objc func updateTimeOfLastUpdate() {

        if let timeOfLastUpdate = ZagwebDataSetManager.dataSets.last?.date as NSDate? {
            DispatchQueue.main.async {
                self.footerLabel.setText("Updated: \(timeOfLastUpdate.timeAgoInWords)")
            }
        } else {
            print("Getting time of last update failed")
        }
    }

    // MARK: - Notification Center

    private func setupNotificationCenter() {
        notificationCenter.addObserver(forName: NSNotification.Name(InterfaceController.UserLoggedInNotificaiton), object: nil, queue: nil) { (_) -> Void in
            DispatchQueue.main.async {
                self.updateDisplay()
            }
        }
        notificationCenter.addObserver(forName: NSNotification.Name(InterfaceController.UserLoggedOutNotification), object: nil, queue: nil) { (_) -> Void
            in
            DispatchQueue.main.async {
                ZagwebDataSetManager.purgeDataSets()
                self.updateDisplay()
            }

        }
    }

}

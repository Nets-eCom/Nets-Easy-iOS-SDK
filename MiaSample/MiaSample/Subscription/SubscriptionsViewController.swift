//
//  SubscriptionsViewController.swift
//  MiaSample
//
//  Created by Luke on 09/03/2020.
//  Copyright © 2020 Nets AS. All rights reserved.
//

import UIKit
import Mia

class SubscriptionsViewController: UITableViewController {
    
    let api = EasyAPI()
    
    @PersistedArray((Settings.subscriptionsKey), defaultValue: [])
    var subscriptions: [Subscription]
    
    let emptySubscriptionsBackgroundLabel: UILabel = {
        let label = UILabel()
        label.text = .messageEmptySubscriptionList
        label.textColor = .darkText
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Init
    
    let shouldPresentAddSubscriptionAlert: Bool
        
    required init(shouldPresentAddSubscriptionAlert: Bool = false) {
        self.shouldPresentAddSubscriptionAlert = shouldPresentAddSubscriptionAlert
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Subscriptions"
        view.backgroundColor = .appBackground
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.register(SubscriptionCell.self, forCellReuseIdentifier: SubscriptionCell.className)
        tableView.backgroundView = emptySubscriptionsBackgroundLabel
        tableView.tableFooterView = UIView() // Removes line separator for empty cells
        tableView.allowsSelection = false
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(addSubscription))
        ]
        
        if shouldPresentAddSubscriptionAlert {
            addSubscription()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Actions
    
    @objc func addSubscription() {
        let alert = UIAlertController.init(
            titled: .titleAddSubscription,
            message: .messageAddSubscription(
                orderAmount: Float(Order.shared.amount) / 100,
                currency: Order.shared.currency
            ),
            actionTitle: .add)
        { _ in
            self.api.createSubscription(
                amount: Order.shared.amount,
                currency: Order.shared.currency,
                checkout: EasyAPI.Checkout(),
                success: self.presentMiaCheckout(_:),
                failure: self.updateUI(withError:)
            )
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func chargeSubscription(_ subscriptionID: String) {
        let alert = UIAlertController.init(
            titled: .titleChargeSubscription,
            message: .messageChargeSubscription(amount: Order.shared.amount, currency: Order.shared.currency),
            actionTitle: "Charge")
        { _ in
            self.api.chargeSubscription(
                subscriptionID: subscriptionID,
                amount: Order.shared.amount,
                currency: Order.shared.currency,
                success: self.updateUIWithChargeSuccess(_:),
                failure: self.updateUI(withError:)
            )
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentMiaCheckout(_ payment: SubscriptionRegistration) {
        let success: (MiaCheckoutController) -> Void = { controller in
            self.stopServer()
            controller.dismiss(animated: true) {
                self.api.fetchSubscriptionPayment(
                    paymentID: payment.paymentId,
                    success: self.fetchNewSubscriptionDetails(_:),
                    failure: self.updateUI(withError:)
                )
            }
        }

        let cancellation: (MiaCheckoutController) -> Void = { controller in
            self.stopServer()
            controller.dismiss(animated: true)
        }

        let failure: (MiaCheckoutController, Error) -> Void = { controller, error in
            self.stopServer()
            controller.dismiss(animated: true) {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }

        let miaCheckoutController = MiaSDK.checkoutControllerForPayment(
            withID: payment.paymentId,
            paymentURL: payment.hostedPaymentPageUrl,
            isEasyHostedWithRedirectURL: Constant().testReturnUrl,
            success: success,
            cancellation: cancellation,
            failure: failure
        )
        
        // Start server to host embedded checkout and/or terms-and-conditions page
        ServerManager.shared.start(paymentId: payment.paymentId)
        
        present(miaCheckoutController, animated: true, completion: nil)
    }
    
    private func fetchNewSubscriptionDetails(_ details: SubscriptionPaymentDetails) {
        api.fetchSubscriptionDetails(
            subscriptionID: details.payment.subscription.id,
            success: self.updateUI(withNew:),
            failure: self.updateUI(withError:)
        )
    }
    
    private func updateUI(withError error: AnyFetchError) {
        showAlert(title: "Error", message: error.errorMessage)
    }
    
    private func updateUI(withNew subscription: SubscriptionDetails) {
        showLeftAlignedAlert(
            title: .titleNewSubscriptionCreated,
            message: .messageNewSubscriptionCreated(subscription.subscriptionId)
        )
        let newItemRow = 0
        subscriptions.insert(Subscription(subscriptionDetails: subscription), at: newItemRow)
        tableView.insertRows(at: [IndexPath(row: newItemRow, section: 0)], with: .fade)
    }
    
    private func updateUIWithChargeSuccess(_ charge: ChargeSubscriptionResponse) {
        showLeftAlignedAlert(
            title: .titleChargeSuccessful,
            message: .messageChargeSucessful(chargeID: charge.chargeId, paymentID: charge.paymentId)
        )
    }
    
    // MARK: UITableViewDatasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptySubscriptionsBackgroundLabel.isHidden = (0 < subscriptions.count)
        return subscriptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.className, for: indexPath)
        let subscription = subscriptions[indexPath.row]
        
        cell.textLabel?.textColor = UIColor.systemBlue
        cell.textLabel?.attributedText = subscription.titleText
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.attributedText = subscription.detailsText
        cell.detailTextLabel?.numberOfLines = 0
        cell.imageView?.image = #imageLiteral(resourceName: "Card")
        cell.setNeedsDisplay()
        
        let subscriptionCell = cell as! SubscriptionCell
        subscriptionCell.setChargeButtonStyle(active: Settings.isChargingPaymentEnabled)
        subscriptionCell.chargeAction = { [weak self] in
            guard let self = self else { return }
            guard Settings.isChargingPaymentEnabled else {
                self.showAlert(title: .titleChargeDisabled, message: .messageEnableChargeInSettings)
                return
            }
            
            self.chargeSubscription(subscription.id)
        }
                         
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        /// Easy API currently does not support deleting a subscription.
        /// This implementation removes cached subscription from the client for test convenience
        subscriptions.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
}

// MARK: Strings

extension String {
    static let subscribe = "Subscribe"
    static let titleAddSubscription = "Add Subscription"
    static let titleChargeSubscription = "Charge Subscription"
    static let titleChargeDisabled = "Charge Disabled"
    static let titleChargeSuccessful = "Charge Successful"
    static let titleNewSubscriptionCreated = "New Subscription Created"
    static let messageEmptySubscriptionList = "There are no subscriptions"
    static let messageEnableChargeInSettings = "Charging can be enabled in Settings when activating developer mode"
    static let add = "Add"
    static let cancel = "Cancel"
    
    static func messageAddSubscription(orderAmount: Float, currency: String) -> String {
        """
        Order amount \(orderAmount.priceText) \(currency) will be charged!
        
        (The subscription will be created with charge interval of 0, therefore chargeable anytime using the payment method added when creating the subscription)
        """
    }
    
    static func messageChargeSubscription(amount: Int, currency: String) -> String {
        "Order Amount: \((Float(amount) / 100).priceText) \(currency)"
    }
    
    static func messageChargeSucessful(chargeID: String, paymentID: String) -> String {
        "Charge ID: \(chargeID)\nPayment ID: \(paymentID)"
    }
    
    static func messageNewSubscriptionCreated(_ subscriptionID: String) -> String {
        "Subscription ID:\n\(subscriptionID)"
    }
}

extension Float {
    var priceText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter.string(from: self as NSNumber)!
    }
}

// MARK: Colors

extension UIColor {
    static var appBackground: UIColor {
        if #available(iOS 13.0, *) { return UIColor.systemBackground }
        return UIColor.white
    }
    
    static var appTitle: UIColor {
        if #available(iOS 13.0, *) { return UIColor.label }
        return .black
    }
}

// MARK: Utilities

extension NSObject {
    static var className: String { NSStringFromClass(Self.self) }
}


// MARK: UIAlertController

extension UIAlertController {
    convenience init(
        titled title: String,
        message: String,
        actionTitle: String,
        action: @escaping (UIAlertAction) -> Void) {
        
        self.init(title: title, message: "", preferredStyle: .alert)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let attributedMessage: NSMutableAttributedString = NSMutableAttributedString(
            string: message,
            attributes: [
                .paragraphStyle : paragraphStyle,
                .font : UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .light)
            ]
        )
        setValue(attributedMessage, forKey: "attributedMessage")
        addAction(UIAlertAction(title: actionTitle, style: .default, handler: action))
        addAction(UIAlertAction(title: .cancel, style: .cancel, handler: nil))
    }
}

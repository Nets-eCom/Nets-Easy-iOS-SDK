//
//  SettingsViewController.swift
//  MiaSample
//
//  MIT License
//
//  Copyright (c) 2020 Nets Denmark A/S
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import Mia
import DropDown

enum Settings {
    @Persisted(.isProductionEnvironment, defaultValue: false)
    static var isProductionEnvironment: Bool
    
    @Persisted(.isChargingPaymentEnabled, defaultValue: false)
    static var isChargingPaymentEnabled: Bool
    
    @Persisted(.handlingConsumerData, defaultValue: HandlingConsumerData.none.rawValue)
    static var handlingConsumerData: String
    
    static var userProfile: Profile? {
        get {
            guard let data = userProfileData else { return nil }
            return try? JSONDecoder().decode(Profile.self, from: data)
        }
        set(profile) {
            let encoded = try? JSONEncoder().encode(profile)
            userProfileData = encoded
        }
    }
    
    @Persisted(.userProfileData, defaultValue: nil)
    private static var userProfileData: Data?
    
    // MARK: Environment Settings
    
    @Persisted(.testEnvironmentSecretKey, defaultValue: nil)
    static var testEnvironmentSecretKey: String?
    
    @Persisted(.testCheckoutKey, defaultValue: nil)
    static var testCheckoutKey: String?
    
    @Persisted(.productionCheckoutKey, defaultValue: nil)
    static var productionCheckoutKey: String?
    
    @Persisted(.productionSecretKey, defaultValue: nil)
    static var productionSecretKey: String?
    
    /// Returns persistence key for current environment
    static var subscriptionsKey: PersistanceKey {
        isProductionEnvironment ? .productionSubscriptions : .testSubscriptions
    }
}


class SettingsViewController: UIViewController {
    
    @IBOutlet weak var applicationVersionLabel: UILabel!
    @IBOutlet weak var productionSwitch: UISwitch!
    
    //This switch is used to charge the payment after completion of the payment from the SDK.
    //Refer our documentation for the complete payment flow.
    @IBOutlet weak var chargePaymentSwitch: UISwitch!
    
    @IBOutlet weak var chargePaymentStackView: UIStackView!
    @IBOutlet weak var handlingConsumetDataSelectionButton: MiaSamplePickerButton!

    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addShadow()
        showApplicationVersion()
        addActionForSwitches()
        setupHandlineConsumerDataTypeButton()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: IBActions
    @IBAction func changeSecretKeys(_ sender: UIButton) {
        postNotification(name: "MiaSampleKeyInput")
        postNotification(name: "MiaSampleSideMenu")
    }
    
    @IBAction func openSubscriptions(_ sender: Any) {
        let navigationController: UINavigationController = {
            let subscriptionsViewController = SubscriptionsViewController()
            subscriptionsViewController.navigationItem.leftBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissPresentedController(_:)))
            ]
            return UINavigationController(rootViewController: subscriptionsViewController)
        }()
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func dismissPresentedController(_: UIBarButtonItem) {
        guard presentedViewController != nil else { return }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showClearingAlert(_ sender: UIButton) {
        createAlert()
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        postNotification(name: "EditProfile")
        postNotification(name: "MiaSampleSideMenu")
    }
}

// MARK: fileprivate functions
extension SettingsViewController {
    fileprivate func addShadow() {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 2
    }
    
    fileprivate func showApplicationVersion() {
        let technicalString = " (\(MIATechnicalVersionString))"
        let semanticString = MIASemanticVersionString
        
        let font = UIFont.boldSystemFont(ofSize: 15)
        let attributes = [NSAttributedString.Key.font: font]
        let attributedBoldString = NSMutableAttributedString(string: semanticString, attributes: attributes)
        
        let normalString = NSMutableAttributedString(string:technicalString)
        
        attributedBoldString.append(normalString)
        self.applicationVersionLabel.attributedText = attributedBoldString
        
    }
    
    
    fileprivate func addActionForSwitches() {
        self.productionSwitch.isOn = Settings.isProductionEnvironment
        self.productionSwitch.addTarget(self, action: #selector(productionSwitchChanged(_:)), for: .valueChanged)
        
        self.chargePaymentSwitch.isOn = Settings.isChargingPaymentEnabled
        self.chargePaymentSwitch.addTarget(self, action: #selector(chargePaymentSwitchChanged(_:)), for: .valueChanged)
    }
    
    fileprivate func setupHandlineConsumerDataTypeButton() {
        Settings.handlingConsumerData = HandlingConsumerData.none.rawValue
        self.handlingConsumetDataSelectionButton.setUpHandlingConsumerDataTypePicker()
    }
    
    @objc fileprivate func productionSwitchChanged(_ urlSwitch: UISwitch) {
        Settings.isProductionEnvironment = urlSwitch.isOn
    }
    
    @objc fileprivate func chargePaymentSwitchChanged(_ urlSwitch: UISwitch) {
        Settings.isChargingPaymentEnabled = urlSwitch.isOn
    }
    
    fileprivate func createAlert() {
        let alertController = UIAlertController(title: "", message:
            "Do you really want to clear all cookies and caches ?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.clearProfileData()
            self.clearCookiesAndCaches()
        }))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func clearCookiesAndCaches() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        let cookieJar = HTTPCookieStorage.shared
        guard let cookies = cookieJar.cookies else {return}
        
        for cookie in cookies {
            cookieJar.deleteCookie(cookie)
        }
    }
    
    fileprivate func clearProfileData(){
        ProfileHelper.shared.removeProfileDataFromDefaults()
    }
}

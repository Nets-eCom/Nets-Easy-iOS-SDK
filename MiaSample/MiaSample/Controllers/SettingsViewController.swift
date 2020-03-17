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


class SettingsViewController: UIViewController {
    
    @IBOutlet weak var applicationVersionLabel: UILabel!
    @IBOutlet weak var productionSwitch: UISwitch!
    
    //This switch is used to charge the payment after completion of the payment from the SDK.
    //Refer our documentation for the complete payment flow.
    @IBOutlet weak var chargePaymentSwitch: UISwitch!
    
    @IBOutlet weak var chargePaymentStackView: UIStackView!
    @IBOutlet weak var integrationTypeSelectionButton: MiaSamplePickerButton!
    @IBOutlet weak var handlingConsumetDataSelectionButton: MiaSamplePickerButton!

    
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addShadow()
        showApplicationVersion()
        addActionForSwitches()
        setupIntegrationTypeButton()
        setupHandlineConsumerDataTypeButton()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        integrationTypeSelectionButton.updateDropDownButton(with: .IntegrationType)
    }
    
    
    // MARK: IBActions
    @IBAction func changeSecretKeys(_ sender: UIButton) {
        postNotification(name: "MiaSampleKeyInput")
        postNotification(name: "MiaSampleSideMenu")
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
        self.productionSwitch.isOn = UserDefaults.standard.bool(forKey: "MiaSampleProductionEnvironment")
        self.productionSwitch.addTarget(self, action: #selector(productionSwitchChanged(_:)), for: .valueChanged)
        
        self.chargePaymentSwitch.isOn = UserDefaults.standard.bool(forKey: "MiaSampleChargePayment")
        self.chargePaymentSwitch.addTarget(self, action: #selector(chargePaymentSwitchChanged(_:)), for: .valueChanged)
    }
    
    fileprivate func setupIntegrationTypeButton() {
        UserDefaults.standard.set(CheckoutType.HostedPaymentWindow.rawValue, forKey: "MiaSampleIntegrationType")
        UserDefaults.standard.synchronize()
        self.integrationTypeSelectionButton.setUpIntegrationTypePicker()
    }
    
    fileprivate func setupHandlineConsumerDataTypeButton() {
        UserDefaults.standard.set(HandlingConsumerData.None.rawValue, forKey: "MiaSampleHandlingConsumerDataType")
        UserDefaults.standard.synchronize()
        self.handlingConsumetDataSelectionButton.setUpHandlingConsumerDataTypePicker()
    }
    
    @objc fileprivate func productionSwitchChanged(_ urlSwitch: UISwitch) {
        UserDefaults.standard.set(urlSwitch.isOn, forKey: "MiaSampleProductionEnvironment")
        UserDefaults.standard.synchronize()
    }
    
    @objc fileprivate func chargePaymentSwitchChanged(_ urlSwitch: UISwitch) {
        UserDefaults.standard.set(urlSwitch.isOn, forKey: "MiaSampleChargePayment")
        UserDefaults.standard.synchronize()
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
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func clearProfileData(){
        ProfileHelper.shared.removeProfileDataFromDefaults()
    }
}

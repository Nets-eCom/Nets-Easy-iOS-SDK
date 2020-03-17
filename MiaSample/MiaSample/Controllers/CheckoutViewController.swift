//
//  ViewController.swift
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

class CheckoutViewController: UIViewController {
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var currencyPicker: CurrencyPickerField!
    
    @IBOutlet weak var buttonStackview: UIStackView!
    
    fileprivate var urlString = ""
    
    fileprivate let currencies = ["SEK", "DKK", "NOK"]
    
    fileprivate var currencyCode: String {
        return currencyPicker.currencyCode
    }
    
    fileprivate var formattedInputValue: Double? {
        guard self.amountTextField.text != nil else {
            return nil
        }
        
        let formattedString = self.amountTextField.text!.replacingOccurrences(of: ",", with: ".")
        return Double(formattedString)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.delegate = self
        currencyPicker.delegate = self
        
        if let temp = self.getIPAddress() {
            self.urlString = temp
            print(self.urlString)
        }
        
        self.addButtons()
        self.setupCurrencyPicker()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(disableTouching),
                                               name: NSNotification.Name("MiaSampleDisableTouching"),
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.contentScrollView.scrollToBottom(animated: false)
    }
    
    @IBAction func openSideMenu(_ sender: UIButton) {
        postNotification(name: "MiaSampleSideMenu")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CheckoutViewController {
    fileprivate func buy(total:Int) {
        if self.urlString != "" {
            self.showIndicator(show: true) {
                
                let integrationType  = UserDefaults.standard.integer(forKey: "MiaSampleIntegrationType")
                let handlingConsumerDataType  = UserDefaults.standard.integer(forKey: "MiaSampleHandlingConsumerDataType")

                if(handlingConsumerDataType == HandlingConsumerData.InjectAddess.rawValue || handlingConsumerDataType == HandlingConsumerData.NoShippingMode.rawValue){
                    if let profile = ProfileHelper.shared.getProfile() {
                        let str = ProfileHelper.shared.getMissingParameters(handlingConsumerDataType:handlingConsumerDataType, profile: profile)
                        if(!str.isEmpty){
                            self.showIndicator(show: false, {
                               self.showLeftAlignedAlert(title: "Please update the following in profile page in settings", message: "\n"+str)
                           })
                           return
                        }
                    } else {
                        self.showIndicator(show: false, {
                            self.showAlert(title: "", message: "Please update user profile in settings")
                        })
                        return
                    }
                }
                
                RequestManager.shared.getPaymentId(ipAddress: self.urlString, total: total, currency: self.currencyCode, integrationType: integrationType, handlingConsumerDataType:handlingConsumerDataType){ (result, paymentId, checkoutURL, errorMsg) in
                    self.showIndicator(show: false, {
                        if (result) {
                            
                            var paymentURL = checkoutURL
                            var easyHostedRedirectURL: String? = Constant().testReturnUrl
                            
                            // Local-hosted checkout
                            if integrationType == CheckoutType.EmbeddedCheckout.rawValue {
                                paymentURL = self.urlString
                                easyHostedRedirectURL = nil
                            }
                                                        
                            // Start server to host embedded checkout and/or terms-and-conditions page
                            ServerManager.shared.start(paymentId: paymentId)
                            
                            let success: (MiaCheckoutController) -> Void = { controller in
                                self.stopServer()
                                controller.dismiss(animated: true) { self.getPayement(forID: paymentId) }
                            }
                            
                            let cancellation: (MiaCheckoutController) -> Void = { controller in
                                self.stopServer()
                                controller.dismiss(animated: true) { self.getPayement(forID: paymentId) }
                            }
                            
                            let failure: (MiaCheckoutController, Error) -> Void = { controller, error in
                                self.stopServer()
                                controller.dismiss(animated: true) {
                                    self.showAlert(title: "", message: error.localizedDescription)
                                }
                            }
                            
                            let miaSDK = MiaSDK.checkoutControllerForPayment(
                                withID: paymentId,
                                paymentURL: paymentURL,
                                isEasyHostedWithRedirectURL: easyHostedRedirectURL,
                                success: success,
                                cancellation: cancellation,
                                failure: failure
                            )
                            
                            self.present(miaSDK, animated: true, completion: nil)
                            
                        } else {
                            self.showAlert(title: "", message: errorMsg)
                        }
                    })
                }
            }
        } else {
            self.showAlert(title: "", message: "Cannot get IP Address of the phone")
        }
    }
    
    fileprivate func charge(paymentID: String, total:Int) {
        self.showIndicator(show: true, {
            RequestManager.shared.chargePayment(paymentId: paymentID, total: total, completion: { (result) in
                self.showIndicator(show: false, {
                    if result {
                        self.showAlert(title: "", message: "Process is successful")
                    } else {
                        self.showAlert(title: "", message: "Process is failed")
                    }
                })
            })
        })
    }
    
    fileprivate func cancel(paymentID: String, total:Int) {
        self.showIndicator(show: true) {
            RequestManager.shared.cancelPayment(paymentId: paymentID, total: total, completion: { (result) in
                self.showIndicator(show: false, {
                    if result {
                        self.showAlert(title: "", message: "Process is successful (cancel)")
                    } else {
                        self.showAlert(title: "", message: "Process is failed")
                    }
                })
            })
        }
    }
    
    fileprivate func getPayement(forID paymentID: String)
    {
        self.showIndicator(show: true) {
            RequestManager.shared.getPayment(paymentId: paymentID, completion: { (result , paymentSuccess, isAmountReserved) in
                self.showIndicator(show: false, {
                    if(result) {
                        if(paymentSuccess) {
                            if isAmountReserved {
                                if self.formattedInputValue != nil && self.formattedInputValue! > 0 {
                                   let temp = Int(self.formattedInputValue! * 100)
                                   if Constant.chargePayment {
                                       self.charge(paymentID: paymentID,total: temp)
                                    } else {
                                       self.cancel(paymentID: paymentID,total: temp)
                                    }
                                } else {
                                self.showAlert(title: "", message: "Please add a non-zero value.")
                                }
                            } else {
                                self.showAlert(title: "", message: "Process is successful")
                            }
                        } else {
                            self.showAlert(title: "", message: "Process is canceled")
                        }
                    }else {
                        self.showAlert(title: "", message: "Process is failed")
                    }
                })
            })
        }
    }
    
    fileprivate func addButtons() {
        let buyButton = bounceButton()
        buyButton.setTitle("Buy", for: .normal)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        buyButton.backgroundColor = .orange
        buyButton.layer.cornerRadius = 5
        buyButton.addTarget(self, action: #selector(self.buyWithNormalFlow), for: .touchUpInside)
        
        self.buttonStackview.addArrangedSubview(buyButton)
        
        self.buttonStackview.distribution = .fillEqually
        self.buttonStackview.spacing = 10.0
    }
    
    fileprivate func setupCurrencyPicker() {
        currencyPicker.currencies = currencies
        currencyPicker.delegate = self
    }
    
    @objc fileprivate func buyWithNormalFlow() {
        if formattedInputValue != nil && formattedInputValue! > 0 {
            let temp = Int(self.formattedInputValue! * 100)
            self.buy(total: temp)
        } else {
            self.showAlert(title: "", message: "Please add a non-zero value.")
        }
    }
    
    @objc fileprivate func disableTouching() {
        changeButtonsState(enable: !sideMenuOpen)
    }
    
    fileprivate func changeButtonsState(enable:Bool) {
        self.buttonStackview.isUserInteractionEnabled = enable
        self.amountTextField.isUserInteractionEnabled = enable
        self.currencyPicker.isUserInteractionEnabled = enable
    }
}

// MARK: TextField Delegate
extension CheckoutViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == currencyPicker {
            return false
        }
        else {
            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            
            if(newString.length > maxLength){
                return false
            }
        }
        return true
    }
}


//
//  MiaSamplePickerButton.swift
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
import DropDown
import Mia

var currentIntegrationType = "HostedPaymentPage"
var currentHandlingConsumerDataType = "None"

public enum MiaSamplePickerType {
    case IntegrationType
    case HandlingConsumerData
}

class MiaSamplePickerButton: UIButton {
    
    fileprivate let integrationType = ["HostedPaymentPage","EmbeddedCheckout"]
    fileprivate let handlingConsumerData = ["None","Injected by merchant","No Shipping address"]

    fileprivate var dropDownButton = DropDown()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gray.cgColor
        self.setUpGenericDropDownButton()
    }
    
    func setUpIntegrationTypePicker() {
        self.setTitleColor(UIColor(red: 41/255, green: 134/255, blue: 255/255, alpha: 1), for: .normal)
        self.setUpDropDownButtonWithIntegrationType()
    }
    
    func setUpHandlingConsumerDataTypePicker() {
        self.setTitleColor(UIColor(red: 41/255, green: 134/255, blue: 255/255, alpha: 1), for: .normal)
        self.setUpDropDownButtonWithHandlindDataType()
    }
    
    func setUpCountryPicker() {
        self.setTitleColor(UIColor.black, for: .normal)
        self.setUpDropDownButtonWithCountry()
    }

    func updateDropDownButton(with type: MiaSamplePickerType) {
        var tempIndex = 0
        
        switch type {
            case .IntegrationType:
                tempIndex = self.integrationType.firstIndex(of: currentIntegrationType) ?? 0
            case .HandlingConsumerData:
                tempIndex = self.handlingConsumerData.firstIndex(of: currentHandlingConsumerDataType) ?? 0
        }
        
        self.dropDownButton.selectRow(tempIndex)
    }
    
    fileprivate func setUpGenericDropDownButton() {
        dropDownButton.anchorView = self
        dropDownButton.bottomOffset = CGPoint(x: 0, y: self.bounds.height)
        dropDownButton.direction = .bottom
        DropDown.appearance().backgroundColor = .white
        DropDown.appearance().cornerRadius = 10
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
    }
    
    fileprivate func setUpDropDownButtonWithIntegrationType() {
        self.dropDownButton.dataSource = self.integrationType
        self.setTitle("\(currentIntegrationType) ", for: .normal)
        dropDownButton.selectionAction = { (index, item) in
            currentIntegrationType = item
            self.setTitle("\(currentIntegrationType)", for: .normal)
            Settings.integrationType = index == 0 ?
                IntegrationType.hostedPaymentWindow.rawValue : IntegrationType.embeddedCheckout.rawValue
        }
    }
    
    fileprivate func setUpDropDownButtonWithHandlindDataType() {
        self.dropDownButton.dataSource = self.handlingConsumerData
        self.setTitle("\(currentHandlingConsumerDataType) ", for: .normal)
        dropDownButton.selectionAction = { (index, item) in
            currentHandlingConsumerDataType = item
            self.setTitle("\(currentHandlingConsumerDataType)", for: .normal)
            Settings.handlingConsumerData = {
                switch index {
                case 0: return HandlingConsumerData.none.rawValue
                case 1: return HandlingConsumerData.injectAddress.rawValue
                default: return HandlingConsumerData.noShippingMode.rawValue
                }
            }()
        }
    }
    
    fileprivate func setUpDropDownButtonWithCountry() {
        dropDownButton.direction = .top
        let countryList = ProfileHelper.countryList
        self.dropDownButton.dataSource = countryList.filter { $0["country"] != nil }.map { $0["country"] ?? ""}
        if let profile = ProfileHelper.shared.getProfile() {
            self.setTitle("\(profile.country)", for: .normal)
        } else {
            setTitle("Norway", for: .normal)
        }
        dropDownButton.selectionAction = { (index, item) in
            self.setTitle("\(item)", for: .normal)
        }
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dropDownButton.show()
    }
}

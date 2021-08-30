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
var currentEnvironment = Environment.test.rawValue


public enum MiaSamplePickerType {
    case HandlingConsumerData
    case Environment
}

class MiaSamplePickerButton: UIButton {
    
    fileprivate let handlingConsumerData = ["None","Injected by merchant","No Shipping address"]
    fileprivate let EnvironmentData = [Environment.test.rawValue,Environment.preprod.rawValue,Environment.prod.rawValue]


    fileprivate var dropDownButton = DropDown()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gray.cgColor
        self.setUpGenericDropDownButton()
    }
    
    func setUpHandlingConsumerDataTypePicker() {
        self.setTitleColor(UIColor(red: 41/255, green: 134/255, blue: 255/255, alpha: 1), for: .normal)
        self.setUpDropDownButtonWithHandlindDataType()
    }
    
    func setUpEnvironmentPicker() {
        self.setTitleColor(UIColor(red: 41/255, green: 134/255, blue: 255/255, alpha: 1), for: .normal)
        self.setUpDropDownButtonWithEnvironment()
    }
    
    func setUpCountryPicker() {
        self.setTitleColor(UIColor.black, for: .normal)
        self.setUpDropDownButtonWithCountry()
    }

    func updateDropDownButton(with type: MiaSamplePickerType) {
        var tempIndex = 0
        
        switch type {
            case .HandlingConsumerData:
                tempIndex = self.handlingConsumerData.firstIndex(of: currentHandlingConsumerDataType) ?? 0
            case .Environment:
                tempIndex = self.EnvironmentData.firstIndex(of: currentEnvironment) ?? 0
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
    
    fileprivate func setUpDropDownButtonWithHandlindDataType() {
        self.dropDownButton.dataSource = self.handlingConsumerData
        switch Settings.handlingConsumerData {
        case HandlingConsumerData.none.rawValue:
            self.dropDownButton.selectRow(0)
            currentHandlingConsumerDataType = HandlingConsumerData.none.rawValue
        case HandlingConsumerData.injectAddress.rawValue:
            self.dropDownButton.selectRow(1)
            currentHandlingConsumerDataType = HandlingConsumerData.injectAddress.rawValue
        case HandlingConsumerData.noShippingMode.rawValue:
            self.dropDownButton.selectRow(2)
            currentHandlingConsumerDataType = HandlingConsumerData.noShippingMode.rawValue
        default:
            self.dropDownButton.selectRow(0)
            currentHandlingConsumerDataType = HandlingConsumerData.none.rawValue
        }
        
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
    
    fileprivate func setUpDropDownButtonWithEnvironment() {
        self.dropDownButton.dataSource = self.EnvironmentData
        switch Settings.environment {
        case Environment.test.rawValue:
            self.dropDownButton.selectRow(0)
            currentEnvironment = Environment.test.rawValue
        case Environment.preprod.rawValue:
            self.dropDownButton.selectRow(1)
            currentEnvironment = Environment.preprod.rawValue
        case Environment.prod.rawValue:
            self.dropDownButton.selectRow(2)
            currentEnvironment = Environment.prod.rawValue
        default:
            self.dropDownButton.selectRow(1)
            currentEnvironment = Environment.test.rawValue
        }
        
        self.setTitle("\(currentEnvironment) ", for: .normal)
        dropDownButton.selectionAction = { (index, item) in
            currentEnvironment = item
            self.setTitle("\(currentEnvironment)", for: .normal)
            Settings.environment = {
                switch index {
                case 0: return Environment.test.rawValue
                case 1: return Environment.preprod.rawValue
                case 2: return Environment.prod.rawValue
                default: return Environment.test.rawValue
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

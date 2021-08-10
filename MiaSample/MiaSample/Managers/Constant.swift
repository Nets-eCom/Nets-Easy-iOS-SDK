//
//  Constant.swift
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

import Foundation

class Constant {
    public static var testMode: Bool {
        !Settings.isProductionEnvironment
    }
    
    public static var chargePayment: Bool {
        Settings.isChargingPaymentEnabled
    }
    
    let testSourceURL = "https://test.checkout.dibspayment.eu/v1/checkout.js?v=1"
    let prodSourceURL = "https://checkout.dibspayment.eu/v1/checkout.js?v=1"
    
    let testBaseURL = "https://test.api.dibspayment.eu"
    let prodBaseURL = "https://api.dibspayment.eu"
    
    let testReturnUrl = "eu.nets.mia.sample://miasdk"
    
    let testCancelUrl = "eu.nets.mia.sample://miasdk"

        
    // MARK: private variables
    private var testCheckoutKey: String {
        Settings.testCheckoutKey ?? NetsTest.checkoutKey
    }
    
    private var prodCheckoutKey: String {
        Settings.productionCheckoutKey ?? NetsProduction.checkoutKey
    }
    
    private var testSecretKey: String {
        Settings.testEnvironmentSecretKey ?? NetsTest.secretKey
    }
    
    private var prodSecretKey: String {
        Settings.productionSecretKey ?? NetsProduction.secretKey
    }
    
    // MARK: get credentials and URLs
    func getSourceURL() -> String {
        if Constant.testMode {
            return testSourceURL
        }
        
        return prodSourceURL
    }
    
    func getCheckoutKey() -> String {
        if Constant.testMode {
            return testCheckoutKey
        }
        
        return prodCheckoutKey
    }
    
    func getSecretKey() -> String {
        if Constant.testMode {
            return testSecretKey
        }
        
        return prodSecretKey
    }
    
    func getBaseURL() -> String {
        if Constant.testMode {
            return testBaseURL
        }
        
        return prodBaseURL
    }
    
    func getCheckoutKey(testEnvironment:Bool) -> String {
        if testEnvironment {
            return testCheckoutKey
        }
        
        return prodCheckoutKey
    }
    
    func getSecretKey(testEnvironment:Bool) -> String {
        if testEnvironment {
            return testSecretKey
        }
        
        return prodSecretKey
    }
}

//
//  API.swift
//  MiaSample
//
//  Created by Luke on 04/03/2020.
//  Copyright © 2020 Nets AS. All rights reserved.
//

import Foundation

public class EasyAPI: JSONDecodeDelegate {
    
    var baseURL: URL {
        let test = URL(string: "https://test.api.dibspayment.eu/v1/")!
        let production = URL(string: "https://api.dibspayment.eu/v1/")!
        return Settings.isProductionEnvironment ? production : test
    }
    
    var headers: [String : String] {
        var productionKey: String { Settings.productionSecretKey ?? NetsProduction.secretKey }
        var testKey: String { Settings.testEnvironmentSecretKey ?? NetsTest.secretKey }
        return [
            "Content-Type" : "application/json",
            "Authorization" : "Token \(Settings.isProductionEnvironment ? productionKey : testKey)",
            "commercePlatformTag" : "iOSSDK"
        ]
    }
    
    public init() {
    }
    
    // MARK: JSONDecodeDelegate
    
    public var jsonDecoder = JSONDecoder()
    public var decodeQueue = DispatchQueue.global()
    public var callbackQueue = DispatchQueue.main
    
    // MARK: Create Subscription
    
    /// Creates / registers a new subscription with given parameters
    /// The `checkout` object contains merchant and consumer related details
    func createSubscription(
        amount: Int,
        currency: String,
        checkout: Checkout,
        success: @escaping (SubscriptionRegistration) -> Void,
        failure: ((AnyFetchError) -> Void)?) {
        
        let url = baseURL.appending(path: "payments/")!
        var request = URLRequest(for: url, method: .post, headers: headers)
        request.httpBody = try! JSONEncoder().encode(
            SubscriptionRequest(orderAmount: amount, currency: currency, checkout: checkout)
        )
        URLSession.shared.fetchJson(with: request, decodeDelegate: self, success: success, failure: failure)
    }
    
    // MARK: Fetch Subscription Payment
    
    /// Fetch the payment details of newly created subscription
    /// The response contains a subscription ID which can be used
    /// to fetch subscription details such as payment details
    func fetchSubscriptionPayment(
        paymentID: String,
        success: @escaping (SubscriptionPaymentDetails) -> Void,
        failure: ((AnyFetchError) -> Void)?) {
        
        let url = baseURL.appending(path: "payments/\(paymentID)")!
        let request = URLRequest(for: url, method: .get, headers: headers)
        URLSession.shared.fetchJson(with: request, decodeDelegate: self, success: success, failure: failure)
    }
    
    // MARK: Fetch Subscription Details
    
    /// Fetch subscription details for given ID
    func fetchSubscriptionDetails(
        subscriptionID: String,
        success: @escaping (SubscriptionDetails) -> Void,
        failure: ((AnyFetchError) -> Void)?) {
        
        let url = baseURL.appending(path: "subscriptions/\(subscriptionID)")!
        let request = URLRequest(for: url, method: .get, headers: headers)
        URLSession.shared.fetchJson(with: request, decodeDelegate: self, success: success, failure: failure)
    }
    
    // MARK: Charge Subscription
    
    /// Charge subscription with given amount
    func chargeSubscription(
        subscriptionID: String,
        amount: Int,
        currency: String,
        success: @escaping (ChargeSubscriptionResponse) -> Void,
        failure: ((AnyFetchError) -> Void)?) {
        
        let url = baseURL.appending(path: "subscriptions/\(subscriptionID)/charges")!
        var request = URLRequest(for: url, method: .post, headers: headers)
        
        struct ChargeRequest: Encodable { let order: Order }
        request.httpBody = try! JSONEncoder().encode(
            ChargeRequest(order: Order(currency: currency, amount: amount))
        )
        URLSession.shared.fetchJson(with: request, decodeDelegate: self, success: success, failure: failure)
    }
    
}

// MARK: - Easy API Secrets

enum NetsProduction {
    static let checkoutKey  = "YOUR PRODUCTION CHECKOUT KEY IS HERE"
    static let secretKey    = "YOUR PRODUCTION SECRET KEY"
}

enum NetsTest {
    static let checkoutKey  = "YOUR TEST CHECKOUT KEY IS HERE"
    static let secretKey    = "YOUR TEST SECRET KEY"
}

public enum HandlingConsumerData: String, Equatable {
    case none
    case injectAddress
    case noShippingMode
    
    static var cached: HandlingConsumerData {
        HandlingConsumerData(rawValue: Settings.handlingConsumerData)!
    }
}

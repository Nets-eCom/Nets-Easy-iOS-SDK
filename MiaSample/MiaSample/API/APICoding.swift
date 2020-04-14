//
//  APICoding.swift
//  MiaSample
//
//  Created by Luke on 03/03/2020.
//  Copyright © 2020 Nets AS. All rights reserved.
//

import Foundation

extension EasyAPI {
    /// An _Easy API_ type for `order` with default values for simplicity
    /// Pass an `amount` and `currency` to init an instance
    struct Order: Encodable {
        let items: [Item]
        let reference = "MiaSDK-iOS"
        
        let currency: String
        let amount: Int
        
        init(currency: String, amount: Int) {
            self.currency = currency
            self.amount = amount
            self.items = [
                Item(unitPrice: amount, grossTotalAmount: amount, netTotalAmount: amount)
            ]
        }
        
        struct Item: Encodable {
            let reference = "MiaSDK-iOS", name = "Lightning Cable", unit = "pcs",
            quantity = 1, taxRate = 0, taxAmount = 0,
            
            unitPrice: Int, grossTotalAmount: Int, netTotalAmount: Int
        }
    }
    
    /// An _Easy API_ type for `checkout` containing merchant and consumer details
    /// Default and cached values are set for simplicity
    struct Checkout: Encodable {
        let integrationType = IntegrationType.cached.rawValue
        let merchantHandlesConsumerData = (HandlingConsumerData.cached != .none)
        let consumer: Consumer? = HandlingConsumerData.cached.consumer
        let charge: Bool = true

        let termsUrl = "http://localhost:8080/terms",
        returnURL = "https://127.0.0.1/redirect.php",
        consumerType = ConsumerType()
        
        struct ConsumerType: Encodable {
            let `default` = "B2C",
            supportedTypes = ["B2C", "B2B"]
        }
    }
}

// MARK: Payment Details

/// Response object following subscription creation
struct SubscriptionRegistration: Decodable {
    let paymentId: String,
    hostedPaymentPageUrl: String
}

// MARK: Subscription Request

struct SubscriptionRequest: Encodable {
    let order: EasyAPI.Order
    let checkout: EasyAPI.Checkout
    
    let merchantNumber: String? = nil, notifications: String? = nil
    let subscription: Subscription = Subscription()
    
    init(
        orderAmount amount: Int,
        currency: String,
        checkout: EasyAPI.Checkout) {
        
        self.order = EasyAPI.Order(currency: currency, amount: amount)
        self.checkout = checkout
    }
    
    struct Shipping: Codable {
        let countries: [String] = []
        let merchantHandlesShippingCost: Bool = false
    }
    
    struct Subscription: Codable {
        let endDate: String = DateFormatter.easyAPIFormatted(
            Date(timeIntervalSinceNow: (3 * 12 * 30) * 24 * 3600) // Roughly now + 3 years
        )
        let interval: Int = 0
    }

}

struct ChargeSubscriptionResponse: Decodable {
    let paymentId: String, chargeId: String
}

// MARK: - Payment Details (Subscription)

/// Response object following fetch request of subscription with `paymentId`
/// Object contains subscription ID that can be used to fetch subscription details
struct SubscriptionPaymentDetails: Codable {
    let payment: Payment
    
    struct Payment: Codable {
        let created: String
        let subscription: Subscription
    }

    struct Subscription: Codable {
        let id: String
    }
}

struct PaymentDetails: Codable {
    let paymentType, paymentMethod: String
    let cardDetails: CardDetails
}

struct CardDetails: Codable {
    let maskedPan, expiryDate: String
}

// MARK: SubscriptionDetailsResponse

struct SubscriptionDetails: Decodable {
    let subscriptionId: String
    let frequency, interval: Int
    let endDate: String
    let paymentDetails: PaymentDetails
}

// MARK: Consumer Data

struct Consumer: Codable {
    let email: String?
    let shippingAddress: ShippingAddress?
    let phoneNumber: PhoneNumber?
    let privatePerson: PrivatePerson?
    
    struct ShippingAddress: Codable {
        let postalCode: String?
        let addressLine1: String?
        let addressLine2: String?
        let city: String?
        let country: String?
    }
    
    struct PhoneNumber: Codable {
        let prefix: String
        let number: String
    }
    
    struct PrivatePerson: Codable {
        let firstName: String?
        let lastName: String?
    }
}

extension HandlingConsumerData {
    /// Returns a `consumer` object from cache for the current `HandlingConsumerData` setting
    var consumer: Consumer? {
        switch self {
        case .none: return nil
        case .noShippingMode: return HandlingConsumerData.shippingLessConsumerData
        case .injectAddress: return HandlingConsumerData.injectedConsumerData
        }
    }
    
    /// Returns a `consumer` object for `noShippingMode` setting
    private static var shippingLessConsumerData: Consumer? {
        guard let profile = Settings.userProfile else { return nil }
        return Consumer(
            email: profile.email,
            shippingAddress: Consumer.ShippingAddress(
                postalCode: profile.postalCode,
                addressLine1: nil,
                addressLine2: nil,
                city: nil,
                country: nil
            ),
            phoneNumber: nil,
            privatePerson: nil
        )
    }
    
    /// Returns a `consumer` object for `injectAddress` setting
    private static var injectedConsumerData: Consumer? {
        guard let profile = Settings.userProfile else { return nil }

        // TODO: Fix the country list data structure. An array of dictionaries is unnecessary
        let countryCode = ProfileHelper.countryList.first { $0["country"] == profile.country }?["code"]

        return Consumer(
            email: profile.email,
            shippingAddress: Consumer.ShippingAddress(
                postalCode: profile.postalCode,
                addressLine1: profile.addressLine1,
                addressLine2: profile.addressLine2,
                city: profile.city,
                country: countryCode
            ),
            phoneNumber: Consumer.PhoneNumber(prefix: profile.prefix, number: profile.phoneNumber),
            privatePerson: Consumer.PrivatePerson(firstName: profile.firstName, lastName: profile.lastName)
        )
    }
}

// MARK: - Date Formatter

extension DateFormatter {
    /// Returns date formatted for Easy API
    /// e.g. output: "2019-07-18T00:00:00+00:00"
    static func easyAPIFormatted(_ date: Date, timezone: TimeZone = .current) -> String {
        let timezoneOffset: String = {
            DateFormatter.shared.timeZone = timezone
            let seconds = DateFormatter.shared.timeZone.secondsFromGMT()
            let hours = seconds / 3600
            let minutes = abs(seconds / 60 % 60)
            return String(format: "%+.2d:%.2d", hours, minutes)
        }()
        return DateFormatter.shared.string(from: date) + timezoneOffset
    }
    
    private static let shared: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
}

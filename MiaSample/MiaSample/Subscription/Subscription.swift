//
//  Subscription.swift
//  MiaSample
//
//  Created by Luke on 09/03/2020.
//  Copyright © 2020 Nets AS. All rights reserved.
//

import UIKit

/// Subscription model cached and displayed to user (client representation)
class Subscription: NSObject, NSCoding {
    
    var id: String
    var paymentMethod: String?
    let maskedPan: String?
    let endDate: String?
    let cardExpiry: String?
    
    // MARK: Coding

    func encode(with coder: NSCoder) {
        Mirror(reflecting: self).children.forEach {
            coder.encode($0.value, forKey: $0.label!)
        }
    }
    
    required init?(coder: NSCoder) {
        self.id = coder.decodeString(forKey: "id")!
        self.paymentMethod = coder.decodeString(forKey: "paymentMethod")
        self.maskedPan = coder.decodeString(forKey: "maskedPan")
        self.endDate = coder.decodeString(forKey: "endDate")
        self.cardExpiry = coder.decodeString(forKey: "cardExpiry")
    }
    
    // MARK: Init
        
    init(subscriptionDetails details: SubscriptionDetails) {
        self.id = details.subscriptionId
        self.paymentMethod = details.paymentDetails.paymentMethod
        self.maskedPan = details.paymentDetails.cardDetails.maskedPan
        self.endDate = details.endDate
        self.cardExpiry = details.paymentDetails.cardDetails.expiryDate
    }
    
    // MARK: Display Format
    
    lazy var titleText: NSAttributedString = {
        let text = NSMutableAttributedString(
            string: "\(paymentMethod ?? "Unknown Scheme")",
            attributes: [
                .font : UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
                .foregroundColor : UIColor.systemBlue
            ]
        )
        text.append(
            NSAttributedString(
                string: "\n\(maskedPan ?? "…")",
                attributes: [
                    .font : UIFont.systemFont(ofSize: UIFont.systemFontSize),
                    .foregroundColor : UIColor.systemGray
                ]
            )
        )
        return text
    }()
    
    lazy var detailsText: NSAttributedString = {
        let subscriptionEndDate: (month: String, year: String) = {
            let text = endDate ?? "YYYY-MM" // e.g. 2020-03-16T13:00:00...
            let yearEnd = text.index(text.startIndex, offsetBy: 4)
            let year = text[text.startIndex..<yearEnd]
            
            let monthStart = text.index(after: yearEnd)
            let monthEnd = text.index(monthStart, offsetBy: 2)
            
            let month = text[monthStart..<monthEnd]
            return (String(month), String(year))
        }()
        
        let cardExpiry: (month: String, year: String) = {
            let text = self.cardExpiry ?? "MMYY"
            let index = text.index(text.startIndex, offsetBy: 2)
            let month = text[text.startIndex..<index]
            let year = text[index..<text.endIndex]
            return (String(month), String(year))
        }()
                
        let header: [NSAttributedString.Key : Any] = [
            .font : UIFont.boldSystemFont(ofSize: UIFont.systemFontSize * 0.8),
            .foregroundColor : UIColor.appTitle
        ]

        let detail: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.8),
            .foregroundColor : UIColor.systemGray
        ]
        
        let details = NSMutableAttributedString(string: "Subscription Ends: ", attributes: header)
        details.append(NSAttributedString(string: "\(subscriptionEndDate.month) / \(subscriptionEndDate.year)", attributes: detail))
        details.append(NSMutableAttributedString(string: "\nCard Expires: ", attributes: header))
        details.append(NSAttributedString(string: "\(cardExpiry.month) / \(cardExpiry.year)", attributes: detail))
        details.append(NSAttributedString(string: "\n\nSubscription ID: ", attributes: header))
        details.append(NSAttributedString(string: "\(id)", attributes: detail))

        return details
    }()

}

extension NSCoder {
    func decodeString(forKey key: String) -> String? {
        return decodeObject(forKey: key) as? String
    }
}

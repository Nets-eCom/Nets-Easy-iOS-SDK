//
//  RequestManager.swift
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
import SwiftyJSON
import Alamofire
import Mia

public class RequestManager {
    private init() {}
    
    static let shared: RequestManager = RequestManager()
    
    let constant = Constant()
    
    func getPaymentId(ipAddress:String, total:Int, currency:String, integrationType: IntegrationType, handlingConsumerDataType: HandlingConsumerData,
         completion: @escaping (_ result: Bool, _ paymentId: String, _ checkoutURL: String, _ errorMsg : String) -> Void) {
        let price = total - 200
        
        let token = "Token " + constant.getSecretKey()
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let termURL = "http://localhost:8080/terms"
        
        let checkoutDict : NSMutableDictionary = [:]
        
        let profile: Profile? = Settings.userProfile
        
        /**
         * Create the checkout Dict based on the integration type
         * Refer "https://tech.dibspayment.com/easy/checkout-guide" for more details
         */
        
        checkoutDict.setValue(["supportedTypes": ["B2C", "B2B"], "default": "B2C"], forKey: "consumerType")
        checkoutDict.setValue(termURL, forKey: "termsUrl")

        switch integrationType {
        case .embeddedCheckout:
            checkoutDict.setValue(IntegrationType.embeddedCheckout.rawValue, forKey: "integrationType")
            checkoutDict.setValue(ipAddress, forKey: "url")
        case .hostedPaymentWindow:
            checkoutDict.setValue(IntegrationType.hostedPaymentWindow.rawValue, forKey: "integrationType")
            checkoutDict.setValue(constant.testReturnUrl, forKey: "returnURL")
        }
        
        switch handlingConsumerDataType {
            case HandlingConsumerData.injectAddress:
                 let country = ProfileHelper.countryList.filter{ $0["country"] == profile?.country}.map{ $0["code"] ?? ""}
                 let consumer : NSDictionary = ["email": profile?.email ?? "",
                                                    "shippingAddress": [
                                                     "addressLine1": profile?.addressLine1 ?? "",
                                                        "addressLine2": profile?.addressLine2 ?? "",
                                                        "postalCode": profile?.postalCode ?? "",
                                                        "city": profile?.city ?? "",
                                                        "country": country[0]],
                                                    "phoneNumber" : [
                                                     "prefix": profile?.prefix ?? "",
                                                     "number": profile?.phoneNumber ?? ""],
                                                    "privatePerson" : [
                                                     "firstName": profile?.firstName ?? "",
                                                     "lastName": profile?.lastName ?? ""]]
                 checkoutDict.setValue(consumer, forKey: "consumer")
                 checkoutDict.setValue(true, forKey: "merchantHandlesConsumerData")
            case HandlingConsumerData.noShippingMode:
                let consumer : NSDictionary = ["email": profile?.email ?? "",
                                               "shippingAddress": [
                                                   "postalCode": profile?.postalCode ?? ""]]
                checkoutDict.setValue(consumer, forKey: "consumer")
                checkoutDict.setValue(true, forKey: "merchantHandlesConsumerData")
            default: break
        }

        let parameters: Parameters = ["order":
                                        ["items": [
                                            ["reference": "MiaSDK-iOS",
                                             "name": "Lightning Cable",
                                             "quantity": 1,
                                             "unit": "pcs",
                                             "unitPrice": price,
                                             "taxRate": 0,
                                             "taxAmount": 0,
                                             "grossTotalAmount": price,
                                             "netTotalAmount": price] ,
                                            ["reference": "MiaSDK-iOS",
                                             "name": "Shipping Cost",
                                             "quantity": 1,
                                             "unit": "pcs",
                                             "unitPrice": 200,
                                             "taxRate": 0,
                                             "taxAmount": 0,
                                             "grossTotalAmount": 200,
                                             "netTotalAmount": 200] ],
                                         "amount": total,
                                         "currency": currency,
                                         "reference": "MiaSDK-iOS" ],
                                      "checkout": checkoutDict ]
        
        let link = constant.getBaseURL() + "/v1/payments"
        
        Alamofire.request(link ,method:.post,parameters: parameters,encoding: JSONEncoding.default,headers:headers).responseJSON {response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var paymentId = ""
                var checkoutURL = ""
                
                if(json["paymentId"].string != nil){
                    paymentId = json["paymentId"].stringValue
                }
                if(json["hostedPaymentPageUrl"].string != nil){
                    checkoutURL = json["hostedPaymentPageUrl"].stringValue
                }
                
                if paymentId != ""{
                    completion(true,paymentId,checkoutURL,"")
                } else {
                    completion(false,"","","There was an unexpected error. Please make a query call to see the details of error.")
                }
            case .failure(let error):
                completion(false,"","",error.localizedDescription)
            }
        }
    }
    
    func chargePayment(paymentId:String, total:Int, completion: @escaping (_ result: Bool) -> Void) {
        let price = total - 200
        
        let token = "Token " + constant.getSecretKey()
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = ["amount": total,
                                      "orderItems": [
                                        ["reference": "MiaSDK-iOS",
                                         "name": "Lightning Cable",
                                         "quantity": 1,
                                         "unit": "pcs",
                                         "unitPrice": price,
                                         "taxRate": 0,
                                         "taxAmount": 0,
                                         "grossTotalAmount": price,
                                         "netTotalAmount": price],
                                        ["reference": "MiaSDK-iOS",
                                         "name": "Shipping Cost",
                                         "quantity": 1,
                                         "unit": "pcs",
                                         "unitPrice": 200,
                                         "taxRate": 0,
                                         "taxAmount": 0,
                                         "grossTotalAmount": 200,
                                         "netTotalAmount": 200]]]
        
        let link = constant.getBaseURL() + "/v1/payments/\(paymentId)/charges"
        
        Alamofire.request(link ,method:.post,parameters: parameters,encoding: JSONEncoding.default,headers:headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if json["chargeId"].string != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(_):
                completion(false)
            }
        }
    }
    
    func cancelPayment(paymentId:String, total:Int, completion: @escaping (_ result: Bool) -> Void) {
        let price = total - 200
        
        let token = "Token " + constant.getSecretKey()
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let parameters: Parameters = ["amount": total,
                                      "orderItems": [
                                        ["reference": "MiaSDK-iOS",
                                         "name": "Lightning Cable",
                                         "quantity": 1,
                                         "unit": "pcs",
                                         "unitPrice": price,
                                         "taxRate": 0,
                                         "taxAmount": 0,
                                         "grossTotalAmount": price,
                                         "netTotalAmount": price],
                                        ["reference": "MiaSDK-iOS",
                                         "name": "Shipping Cost",
                                         "quantity": 1,
                                         "unit": "pcs",
                                         "unitPrice": 200,
                                         "taxRate": 0,
                                         "taxAmount": 0,
                                         "grossTotalAmount": 200,
                                         "netTotalAmount": 200]]]
        
        let link = constant.getBaseURL() + "/v1/payments/\(paymentId)/cancels"
        
        Alamofire.request(link ,method:.post,parameters: parameters,encoding: JSONEncoding.default,headers:headers).response { response in
            if let statusCode = response.response?.statusCode {
                if statusCode == 204 {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(true)
            }
        }
    }
    
    func getPayment(paymentId:String, completion: @escaping (_ result: Bool , _ paymentSuccess: Bool, _ isAmountReserved: Bool) -> Void) {
        
        let token = "Token " + constant.getSecretKey()

        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let link = constant.getBaseURL() + "/v1/payments/\(paymentId)"
        
        Alamofire.request(link ,method:.get,parameters: nil,encoding: JSONEncoding.default,headers:headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let payment = json["payment"].dictionary {
                    
                    if(payment["summary"]?.dictionary != nil  && payment["orderDetails"]?.dictionary != nil) {
                        
                        let summary = json["payment"]["summary"].dictionary
                        let orderDetails = json["payment"]["orderDetails"].dictionary
                        
                        if(summary!["reservedAmount"]?.double != nil && orderDetails!["amount"]?.double != nil
                            && summary!["reservedAmount"]?.double == orderDetails!["amount"]?.double) {
                            completion(true,true,true)
                        }else if(summary!["chargedAmount"]?.double != nil && orderDetails!["amount"]?.double != nil
                            && summary!["chargedAmount"]?.double == orderDetails!["amount"]?.double) {
                            completion(true,true,false)
                        } else if (summary!["reservedAmount"] == nil && summary!["cancelledAmount"] == nil
                            && summary!["chargedAmount"] == nil && summary!["refundedAmount"] == nil) {
                            completion(true,false,false)
                        } else {
                            completion(false,false,false)
                        }
                    } else {
                        completion(true,false,false)
                    }
                } else {
                    completion(false,false,false)
                }
            case .failure(_):
                completion(false,false,false)
            }
        }
    }
}

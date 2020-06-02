//
//  Copyright (c) 2019 Nets Denmark A/S
//
//  NETS DENMARK A/S, ("NETS"), FOR AND ON BEHALF OF ITSELF AND ITS
//  SUBSIDIARIES AND AFFILIATES UNDER COMMON CONTROL, IS WILLING TO
//  LICENSE THE SOFTWARE TO YOU ONLY UPON THE CONDITION THAT YOU ACCEPT
//  ALL OF THE TERMS CONTAINED IN THIS LICENSE AGREEMENT. BY USING THE
//  SOFTWARE YOU ACKNOWLEDGE THAT YOU HAVE READ THE TERMS AND AGREE TO THEM.
//  IF YOU ARE AGREEING TO THESE TERMS ON BEHALF OF A COMPANY OR OTHER LEGAL ENTITY,
//  YOU REPRESENT THAT YOU HAVE THE LEGAL AUTHORITY TO BIND THE LEGAL ENTITY TO
//  THESE TERMS. IF YOU DO NOT HAVE SUCH AUTHORITY, OR IF YOU DO NOT WISH TO BE BOUND
//  BY THE TERMS, YOU MUST NOT USE THE SOFTWARE ON THIS SITE OR ANY OTHER MEDIA ON
//  WHICH THE SOFTWARE IS CONTAINED.
//
//  Software is copyrighted. Title to Software and all associated intellectual
//  property rights is retained by NETS and/or its licensors. Unless enforcement
//  is prohibited by applicable law, you may not modify, decompile, or reverse engineer Software.
//
//  No right, title or interest in or to any trademark, service mark, logo or trade
//  name of NETS or its licensors is granted under this Agreement.
//
//  Permission is hereby granted, to any person obtaining a copy of this software
//  and associated documentation files (the Software"), to deal in the Software without
//  restriction, including without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom
//  the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  Software may only be used for commercial or production purpose together with Easy services
//  (as per https://tech.dibspayment.com/easy) provided from NETS, its subsidiaries
//  or affiliates under common control.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
//  USE OR OTHER DEALINGS IN THE SOFTWARE.
//

using System;

using ObjCRuntime;
using Foundation;
using UIKit;

namespace XamarinMia
{
    [Static]
    partial interface Constants
    {
        // extern double MiaVersionNumber;
        [Field("MiaVersionNumber", "__Internal")]
        double MiaVersionNumber { get; }

        // extern const unsigned char [] MiaVersionString;
        [Field("MiaVersionString", "__Internal")]
        NSString MiaVersionString { get; }

        // extern NSString *const _Nonnull MIASemanticVersionString;
        [Field("MIASemanticVersionString", "__Internal")]
        NSString MIASemanticVersionString { get; }

        // extern NSString *const _Nonnull MIATechnicalVersionString;
        [Field("MIATechnicalVersionString", "__Internal")]
        NSString MIATechnicalVersionString { get; }
    }


    // @interface MiaCheckoutController : UIViewController
    [BaseType(typeof(UIViewController))]
    interface MiaCheckoutController
    {
        // +(MiaCheckoutController * _Nonnull)makeWithPaymentID:(NSString * _Nonnull)paymentID paymentURL:(NSString * _Nonnull)paymentURL redirectURL:(NSString * _Nonnull)redirectURL success:(void (^ _Nonnull)(MiaCheckoutController * _Nonnull))success cancellation:(void (^ _Nonnull)(MiaCheckoutController * _Nonnull))cancellation failure:(void (^ _Nonnull)(MiaCheckoutController * _Nonnull, NSError * _Nonnull))failure;
        [Static]
        [Export("makeWithPaymentID:paymentURL:redirectURL:success:cancellation:failure:")]
        MiaCheckoutController MakeWithPaymentID(string paymentID, string paymentURL, string redirectURL, Action<MiaCheckoutController> success, Action<MiaCheckoutController> cancellation, Action<MiaCheckoutController, NSError> failure);
    }

    // @interface MiaSDK : NSObject
    [BaseType(typeof(NSObject))]
    interface MiaSDK
    {
        // +(MiaCheckoutController * _Nonnull)checkoutControllerForPaymentWithID:(NSString * _Nonnull)paymentID paymentURL:(NSString * _Nonnull)paymentURL isEasyHostedWithRedirectURL:(NSString * _Nullable)redirectURL success:(void (^ _Nonnull)(MiaCheckoutController * _Nonnull))success cancellation:(void (^ _Nonnull)(MiaCheckoutController * _Nonnull))cancellation failure:(void (^ _Nonnull)(MiaCheckoutController * _Nonnull, NSError * _Nonnull))failure;
        [Static]
        [Export("checkoutControllerForPaymentWithID:paymentURL:isEasyHostedWithRedirectURL:success:cancellation:failure:")]
        MiaCheckoutController CheckoutControllerForPaymentWithID(string paymentID, string paymentURL, [NullAllowed] string redirectURL, Action<MiaCheckoutController> success, Action<MiaCheckoutController> cancellation, Action<MiaCheckoutController, NSError> failure);
    }
}


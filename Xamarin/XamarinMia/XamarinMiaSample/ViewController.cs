//
//  MIT License
//
//  Copyright (c) 2019 Nets Denmark A/S
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


using Foundation;
using System;
using UIKit;
using XamarinMia;


namespace XamarinMiaSample
{


    public partial class ViewController : UIViewController
    {
        String paymentIdUrl = "EASY_PAYMENTID_URL";
        String secretKey = "YOUR_SECRET_KEY";
        String returnURL = "YOUR_RETURN_URL";


        public ViewController(IntPtr handle) : base(handle)
        {
        }

        public override void ViewDidLoad()
        {
            base.ViewDidLoad();

            UIButton myButton = new UIButton(UIButtonType.System);
            myButton.Frame = new CoreGraphics.CGRect(0, 0, this.View.Frame.Size.Width - 100, 50);
            myButton.Center = new CoreGraphics.CGPoint(this.View.Frame.Size.Width / 2, this.View.Frame.Size.Height / 2 - 100);
            myButton.Layer.BorderWidth = (System.nfloat)1.0;
            myButton.Layer.BorderColor = UIColor.Black.CGColor;
            myButton.SetTitle("Buy", UIControlState.Normal);
            myButton.TouchUpInside += (sender, e) => {
                getPayementID(false);
            };

            UIButton myButton2 = new UIButton(UIButtonType.System);
            myButton2.Frame = new CoreGraphics.CGRect(0, 0, this.View.Frame.Size.Width - 100, 50);
            myButton2.Center = new CoreGraphics.CGPoint(this.View.Frame.Size.Width / 2, this.View.Frame.Size.Height / 2 + 100);
            myButton2.Layer.BorderWidth = (System.nfloat)1.0;
            myButton2.Layer.BorderColor = UIColor.Black.CGColor;
            myButton2.SetTitle("Subscription", UIControlState.Normal);
            myButton2.TouchUpInside += (sender, e) => {
                getPayementID(true);
            };

            this.Add(myButton);
            this.Add(myButton2);

            // Perform any additional setup after loading the view, typically from a nib.
        }

        public override void ViewDidAppear(bool animated)
        {
            base.ViewDidAppear(animated);
        }
        
        public void presentMiaSDK(string paymentID, String paymentURL)
        {

            MiaCheckoutController miaSDK = MiaSDK.CheckoutControllerForPaymentWithID(paymentID, paymentURL, returnURL,
                (controller) => {
                    // success
                    controller.DismissViewController(true, null);
                    showAlert("Please check payment status to confirm if payment is successful or cancelled", controller);
                },
                (controller) => {
                    controller.DismissViewController(true, null);
                    showAlert("Payment cancelled", controller);
                },
                (controller, error) => {
                    controller.DismissViewController(true, null);
                    showAlert("Error : {$error}", controller);
                });

            this.PresentViewController(miaSDK, true, null);
            
        }

        public void showAlert(String msg, MiaCheckoutController controller)
        {
            //Create Alert 
            var okAlertController = UIAlertController.Create("", msg, UIAlertControllerStyle.Alert);
            //Add Action
            okAlertController.AddAction(UIAlertAction.Create("OK", UIAlertActionStyle.Default, (obj) =>
            {
                
            }));
            // Present Alert
            this.PresentViewController(okAlertController, true, null);
        }


        public void getPayementID(Boolean subscription)
        {
            NSUrl url = new NSUrl(paymentIdUrl);
            NSMutableUrlRequest request = new NSMutableUrlRequest(url);
            NSUrlSession session = null;
            NSUrlSessionConfiguration myConfig = NSUrlSessionConfiguration.DefaultSessionConfiguration;
            session = NSUrlSession.FromConfiguration(myConfig);

            var dictionary = new NSDictionary(
                      "Content-Type", "application/json",
                    "Authorization", secretKey
            );


            if (subscription)
            {
                var date = NSDate.FromTimeIntervalSinceNow((3 * 12 * 30) * 24 * 3600);
                NSDateFormatter dateFormat = new NSDateFormatter();
                dateFormat.DateFormat = "yyyy-MM-dd'T'HH:mm:ss";
                var dateString = dateFormat.ToString(date);

                String data = "{\"subscription\":{\"endDate\":\"{dateString}\",\"interval\":0},\"order\":{\"currency\":\"SEK\",\"amount\":1000,\"reference\":\"MiaSDK-iOS\",\"items\":[{\"unit\":\"pcs\",\"name\":\"Lightning Cable\",\"reference\":\"MiaSDK-iOS\",\"quantity\":1,\"netTotalAmount\":800,\"unitPrice\":800,\"taxRate\":0,\"grossTotalAmount\":800,\"taxAmount\":0},{\"unitPrice\":200,\"quantity\":1,\"grossTotalAmount\":200,\"taxAmount\":0,\"taxRate\":0,\"reference\":\"MiaSDK-iOS\",\"name\":\"Shipping Cost\",\"unit\":\"pcs\",\"netTotalAmount\":200}]},\"checkout\":{\"consumerType\":{\"default\":\"B2C\",\"supportedTypes\":[\"B2C\",\"B2B\"]},\"returnURL\":\"https:\\/\\/127.0.0.1\\/redirect.php\",\"integrationType\":\"HostedPaymentPage\",\"shippingCountries\":[{\"countryCode\":\"SWE\"},{\"countryCode\":\"NOR\"},{\"countryCode\":\"DNK\"}],\"termsUrl\":\"http:\\/\\/localhost:8080\\/terms\"}}";

                request.Body = data.Replace("{dateString}", dateString);
            } else {
                request.Body = "{\"order\":{\"currency\":\"SEK\",\"amount\":1000,\"reference\":\"MiaSDK-iOS\",\"items\":[{\"unit\":\"pcs\",\"name\":\"Lightning Cable\",\"reference\":\"MiaSDK-iOS\",\"quantity\":1,\"netTotalAmount\":800,\"unitPrice\":800,\"taxRate\":0,\"grossTotalAmount\":800,\"taxAmount\":0},{\"unitPrice\":200,\"quantity\":1,\"grossTotalAmount\":200,\"taxAmount\":0,\"taxRate\":0,\"reference\":\"MiaSDK-iOS\",\"name\":\"Shipping Cost\",\"unit\":\"pcs\",\"netTotalAmount\":200}]},\"checkout\":{\"consumerType\":{\"default\":\"B2C\",\"supportedTypes\":[\"B2C\",\"B2B\"]},\"returnURL\":\"https:\\/\\/127.0.0.1\\/redirect.php\",\"integrationType\":\"HostedPaymentPage\",\"shippingCountries\":[{\"countryCode\":\"SWE\"},{\"countryCode\":\"NOR\"},{\"countryCode\":\"DNK\"}],\"termsUrl\":\"http:\\/\\/localhost:8080\\/terms\"}}";
            }
            request.HttpMethod = "POST";
            request.Headers = dictionary;

            NSUrlSessionTask task = session.CreateDataTask(request, (data, response, error) => {
                var json = NSJsonSerialization.Deserialize(data, NSJsonReadingOptions.FragmentsAllowed, out error);
                if((Foundation.NSString)json.ValueForKey((Foundation.NSString)"hostedPaymentPageUrl") != null &&
                    (Foundation.NSString)json.ValueForKey((Foundation.NSString)"paymentId") != null)
                {
                    InvokeOnMainThread(() =>
                    {
                        presentMiaSDK((Foundation.NSString)json.ValueForKey((Foundation.NSString)"paymentId"),
                            (Foundation.NSString)json.ValueForKey((Foundation.NSString)"hostedPaymentPageUrl"));
                    });
                }
            });
            task.Resume();
        }

        public override void DidReceiveMemoryWarning()
        {
            base.DidReceiveMemoryWarning();
            // Release any cached data, images, etc that aren't in use.
        }
    }


}



       

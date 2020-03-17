//
//  ServerManager.swift
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
import GCDWebServer

public class ServerManager {
    var webServer = GCDWebServer()
    
    private init() {}
    
    static let shared: ServerManager = ServerManager()
    
    let constant = Constant()
    
    func start(paymentId:String) {
        guard let htmlFilePath = Bundle.main.path(forResource: "EasyCheckout", ofType: "html") else {return}
        guard var htmlContentString = try? String(contentsOfFile: htmlFilePath, encoding: .utf8) else {return}
        htmlContentString = htmlContentString.replacingOccurrences(of: "REPLACETHIS", with: paymentId)
        htmlContentString = htmlContentString.replacingOccurrences(of: "CHECKOUTKEY", with: constant.getCheckoutKey())
        htmlContentString = htmlContentString.replacingOccurrences(of: "SOURCEURL", with: constant.getSourceURL())
        
        self.webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: { request in
            return GCDWebServerDataResponse(html: htmlContentString)
        })
        
        guard let termHtmlFilePath = Bundle.main.path(forResource: "TermsAndConditions", ofType: "html") else {return}
        guard let termHtmlContentString = try? String(contentsOfFile: termHtmlFilePath, encoding: .utf8) else {return}
        
        self.webServer.addHandler(forMethod: "GET", path: "/terms", request: GCDWebServerRequest.self, processBlock: { request in
            return GCDWebServerDataResponse(html: termHtmlContentString)
        })
        
        self.webServer.start(withPort: 8080, bonjourName: nil)
    }
    
    func stop() {
        self.webServer.stop()
    }
}

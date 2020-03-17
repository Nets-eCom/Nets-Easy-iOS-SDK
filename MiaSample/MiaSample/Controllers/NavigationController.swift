//
//  NavigationController.swift
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

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyInputVC),
                                               name: NSNotification.Name("MiaSampleKeyInput"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(returnToRootView),
                                               name: NSNotification.Name("MiaSamplePopView"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editProfile),
                                               name: NSNotification.Name("EditProfile"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func showKeyInputVC() {
        if !isSettingsPresented() {
            self.performSegue(withIdentifier: "InputKeyViewControllerSegue", sender: nil)
        }
    }
    
    @objc func editProfile(){
        self.performSegue(withIdentifier: "EditProfile", sender: nil)
    }
    
    @objc func returnToRootView() {
        self.popViewController(animated: true)
    }
    
    fileprivate func isSettingsPresented() -> Bool {
        for vc in self.viewControllers {
            if vc.isKind(of: InputKeyViewController.classForCoder()) {
                return true
            }
        }
        
        return false
    }
}

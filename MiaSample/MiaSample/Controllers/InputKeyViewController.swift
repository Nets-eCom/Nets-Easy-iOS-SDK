//
//  InputKeyViewController.swift
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

class InputKeyViewController: UIViewController {
    
    // MARK: Main view properties
    @IBOutlet weak var testSecretKeyTextField: UITextField!
    @IBOutlet weak var testCheckoutKeyTextField: UITextField!
    
    @IBOutlet weak var productionSecretKeyTextField: UITextField!
    @IBOutlet weak var productionCheckoutKeyTextField: UITextField!
    
    // MARK: Confirmation view properties
    @IBOutlet weak var confirmationView: UIView!
    
    @IBOutlet weak var testSecretKeyLabel: UILabel!
    @IBOutlet weak var testCheckoutKeyLabel: UILabel!
    
    @IBOutlet weak var productionSecretKeyLabel: UILabel!
    @IBOutlet weak var productionCheckoutKeyLabel: UILabel!
    
    // MARK: fileprivate variables
    fileprivate let cache = Cache()
    fileprivate let constant = Constant()
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: IBActions
    @IBAction func returnToPreviousView(_ sender: UIBarButtonItem) {
        postNotification(name: "MiaSamplePopView")
        postNotification(name: "MiaSampleSideMenu")
    }
    
    @IBAction func saveSecretKey(_ sender: UIBarButtonItem) {
        addConfirmationView()
    }
    
    @IBAction func cancelNewSecretKeys(_ sender: UIButton) {
        removeConfirmationView()
    }
    
    @IBAction func confirmNewSecretKeys(_ sender: UIButton) {
        if self.testSecretKeyTextField.hasText {
            cache.addObject(object: self.testSecretKeyTextField.text!, forKey: "MiaSampleTestSecretKey")
        }
        
        if self.testCheckoutKeyTextField.hasText {
            cache.addObject(object: self.testCheckoutKeyTextField.text!, forKey: "MiaSampleTestCheckoutKey")
        }
        
        if self.productionSecretKeyTextField.hasText {
            cache.addObject(object: self.productionSecretKeyTextField.text!, forKey: "MiaSampleProductionSecretKey")
        }
        
        if self.productionCheckoutKeyTextField.hasText {
            cache.addObject(object: self.productionCheckoutKeyTextField.text!, forKey: "MiaSampleProductionCheckoutKey")
        }
        
        self.navigationController?.popViewController(animated: true)
        postNotification(name: "MiaSampleSideMenu")
    }
}

// MARK: fileprivate functions
extension InputKeyViewController {
    
    fileprivate func addConfirmationView() {
        self.confirmationView.tag = 101
        var blurEffect:UIBlurEffect = UIBlurEffect()
        blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 102
        view.addSubview(blurView)
        
        confirmationView.center = self.view.center
        confirmationView.layer.shadowColor = UIColor.gray.cgColor
        confirmationView.layer.shadowOpacity = 1
        confirmationView.layer.shadowOffset = CGSize.zero
        confirmationView.layer.shadowRadius = 2
        confirmationView.layer.cornerRadius = 5
        
        testSecretKeyLabel.text = self.testSecretKeyTextField.text ?? ""
        testCheckoutKeyLabel.text = self.testCheckoutKeyTextField.text ?? ""
        
        productionSecretKeyLabel.text = self.productionSecretKeyTextField.text ?? ""
        productionCheckoutKeyLabel.text = self.productionCheckoutKeyTextField.text ?? ""
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            self.view.addSubview(self.confirmationView)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }
    
    fileprivate func removeConfirmationView() {
        if let viewWithTag = self.view.viewWithTag(101) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(102) {
            viewWithTag.removeFromSuperview()
        }
    }
}

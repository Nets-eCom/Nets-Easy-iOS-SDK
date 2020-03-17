//
//  MasterViewController.swift
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

public var sideMenuOpen = false

class MasterViewController: UIViewController {
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var checkoutVCLeadingConstraint: NSLayoutConstraint!
    
    fileprivate var constantLayout:CGFloat = 0
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.constantLayout = self.view.bounds.width * 3 / 4
        
        self.sideMenuConstraint.constant = -constantLayout
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("MiaSampleSideMenu"),
                                               object: nil)
        
        addGestureRecognition()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: fileprivate functions
extension MasterViewController {
    fileprivate func addGestureRecognition() {
        let rightEdge = UISwipeGestureRecognizer(target: self, action: #selector(rightGestureAction))
        rightEdge.direction = .right
        view.addGestureRecognizer(rightEdge)
        
        let leftEdge = UISwipeGestureRecognizer(target: self, action: #selector(leftGestureAction))
        leftEdge.direction = .left
        view.addGestureRecognizer(leftEdge)
    }
    
    @objc fileprivate func leftGestureAction() {
        if sideMenuOpen == true {
            toggleSideMenu()
        }
    }
    
    @objc fileprivate func rightGestureAction() {
        if sideMenuOpen == false {
            toggleSideMenu()
        }
    }
    
    @objc fileprivate func toggleSideMenu() {
        if sideMenuOpen {
            sideMenuConstraint.constant = -constantLayout
            checkoutVCLeadingConstraint.constant = 0
        } else {
            sideMenuConstraint.constant = 0
            checkoutVCLeadingConstraint.constant = constantLayout
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        sideMenuOpen.toggle()
        
        postNotification(name: "MiaSampleDisableTouching")
    }
}

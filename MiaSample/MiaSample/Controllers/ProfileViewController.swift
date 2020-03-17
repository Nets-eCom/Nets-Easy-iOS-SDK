//
//  ProfileViewController.swift
//  MiaSample
//
//  Created by Keval on 26/11/19.
//  Copyright © 2020 Nets AS. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var addressLine1: UITextField!
    @IBOutlet weak var addressLine2: UITextField!
    @IBOutlet weak var postalCode: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var country: MiaSamplePickerButton!
    @IBOutlet weak var prefix: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var scrollView = UIScrollView()

    let prefixMaxLength = 4
    let phoneNumberMaxLength = 12
    let postalCodeMaxLength = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileView.frame = CGRect(x:0, y: 0, width: UIScreen.main.bounds.width-10, height: profileView.frame.height)
        scrollView.contentSize = CGSize(width: profileView.frame.size.width, height: profileView.frame.size.height)
        self.view.addSubview(scrollView)
        scrollView.addSubview(profileView)
        
        country.setUpCountryPicker()
        country.contentHorizontalAlignment = .left;

        
        if let profile:Profile = ProfileHelper.shared.getProfile(){
            email.text = profile.email
            firstName.text = profile.firstName
            lastName.text = profile.lastName
            addressLine1.text = profile.addressLine1
            addressLine2.text = profile.addressLine2
            postalCode.text = profile.postalCode
            city.text = profile.city
            prefix.text = profile.prefix
            phoneNumber.text = profile.phoneNumber
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navigationBarHeight = navigationBar.frame.origin.y + navigationBar.bounds.height + 5
        scrollView.frame = CGRect(x: 5, y: navigationBarHeight, width: UIScreen.main.bounds.width-10, height: UIScreen.main.bounds.height-navigationBarHeight)
    }
    
    @IBAction func saveDetails(_ sender: Any) {
        
        if(!(email.text!.isEmpty) && !self.isValidEmail(emailStr: email.text ?? "")){
            self.showAlert(title: "", message: "Please enter a valid email address")
            return
        }
        
        let profile = Profile(
            firstName: firstName.text ?? "",
            lastName: lastName.text ?? "",
            email: email.text ?? "",
            prefix: prefix.text ?? "",
            phoneNumber: phoneNumber.text ?? "",
            addressLine1: addressLine1.text ?? "",
            addressLine2: addressLine2.text ?? "",
            postalCode: postalCode.text ?? "",
            city: city.text ?? "",
            country: country.titleLabel?.text ?? ""
        )
        
        ProfileHelper.shared.syncProfileToDefaults(profile: profile)
        postNotification(name: "MiaSamplePopView")
        postNotification(name: "MiaSampleSideMenu")
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        postNotification(name: "MiaSamplePopView")
        postNotification(name: "MiaSampleSideMenu")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentString = textField.text! as NSString
        let newString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        switch textField {
            case prefix :  return newString.length <= prefixMaxLength
            case phoneNumber : return newString.length <= phoneNumberMaxLength
            case postalCode : return newString.length <= postalCodeMaxLength
            default: return true
        }
    }
}

public struct Profile : Codable {
    var firstName: String
    var lastName: String
    var email : String
    var prefix: String
    var phoneNumber: String
    var addressLine1: String
    var addressLine2: String
    var postalCode: String
    var city: String
    var country: String
}

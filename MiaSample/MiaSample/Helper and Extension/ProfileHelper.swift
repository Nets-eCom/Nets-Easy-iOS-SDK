//
//  ProfileHelper.swift
//  MiaSample
//
//  Created by Keval on 29/11/19.
//  Copyright © 2020 Nets AS. All rights reserved.
//

import UIKit

class ProfileHelper: NSObject {

    static let shared: ProfileHelper = ProfileHelper()
    
    static let countryList = [["country":"Norway","code":"NOR"],
                              ["country":"Finland","code":"FIN"],
                              ["country":"Denmark","code":"DNK"],
                              ["country":"Sweden","code":"SWE"],
                              ["country":"Albania","code":"ALB"],
                              ["country":"Albania","code":"AND"],
                              ["country":"Armenia","code":"ARM"],
                              ["country":"Austria","code":"AUT"],
                              ["country":"Azerbaijan","code":"AZE"],
                              ["country":"Belgium","code":"BEL"],
                              ["country":"Bulgaria","code":"BGR"],
                              ["country":"Bosnia and Herzegovina","code":"BIH"],
                              ["country":"Belarus","code":"BLR"],
                              ["country":"Switzerland","code":"CHE"],
                              ["country":"Cyprus","code":"CYP"],
                              ["country":"Czechia","code":"CZE"],
                              ["country":"Germany","code":"DEU"],
                              ["country":"Spain","code":"ESP"],
                              ["country":"Estonia","code":"EST"],
                              ["country":"France","code":"FRA"],
                              ["country":"United Kingdom","code":"GBR"],
                              ["country":"Georgia","code":"GEO"],
                              ["country":"Greece","code":"GRC"],
                              ["country":"Croatia","code":"HRV"],
                              ["country":"Hungary","code":"HUN"],
                              ["country":"Ireland","code":"IRL"],
                              ["country":"Iceland","code":"ISL"],
                              ["country":"Italy","code":"ITA"],
                              ["country":"Kazakhstan","code":"KAZ"],
                              ["country":"Liechtenstein","code":"LIE"],
                              ["country":"Lithuania","code":"LTU"],
                              ["country":"Luxembourg","code":"LUX"],
                              ["country":"Latvia","code":"LVA"],
                              ["country":"Monaco","code":"MCO"],
                              ["country":"Moldova","code":"MDA"],
                              ["country":"Macedonia","code":"MKD"],
                              ["country":"Malta","code":"MLT"],
                              ["country":"Montenegro","code":"MNE"],
                              ["country":"Netherlands","code":"NLD"],
                              ["country":"Norway","code":"NOR"],
                              ["country":"Poland","code":"POL"],
                              ["country":"Portugal","code":"PRT"],
                              ["country":"Romania","code":"ROU"],
                              ["country":"Russia","code":"RUS"],
                              ["country":"San Marino","code":"SMR"],
                              ["country":"Serbia","code":"SRB"],
                              ["country":"Slovakia","code":"SVK"],
                              ["country":"Slovenia","code":"SVN"],
                              ["country":"Turkey","code":"TUR"],
                              ["country":"Ukraine","code":"UKR"],
                              ["country":"Vatican City","code":"VAT"]]
    
    func getMissingParameters(handlingConsumerDataType:Int,profile:Profile) -> String {
        var missingParameters = ""
        let mirror = Mirror(reflecting: profile)
        
        switch handlingConsumerDataType {
            case HandlingConsumerData.InjectAddess.rawValue:
                for child in mirror.children {
                    if (child.value as! String == "") {
                        missingParameters.append("* "+child.label!+"\n")
                    }
                }
                missingParameters = missingParameters.replacingOccurrences(of: "* addressLine2\n", with: "")
            
            case HandlingConsumerData.NoShippingMode.rawValue:
                 for child in mirror.children {
                    if ((child.label == "email" || child.label == "postalCode") && child.value as! String == "") {
                         missingParameters.append("* "+child.label!+"\n")
                     }
                 }
            default:
                break
        }

        return missingParameters
    }
    
    func getProfile() -> Profile? {
        if let data =  (UserDefaults.standard.object(forKey: "Profile") as? Data){
            if let profile = try? JSONDecoder().decode(Profile.self, from: data){
                return profile
            }
        }
        return nil
    }
    
    func syncProfileToDefaults(profile:Profile){
        if let encoded = try? JSONEncoder().encode(profile) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "Profile")
            defaults.synchronize()
        }
    }
    
    func removeProfileDataFromDefaults(){
        UserDefaults.standard.removeObject(forKey: "Profile")
        UserDefaults.standard.synchronize()
    }
}

//
//  Persistance.swift
//  MiaSample
//
//  Created by Luke on 30/06/2019.
//  Copyright © 2019 Nets. All rights reserved.
//

import Foundation

// MARK: - Persistance

enum PersistanceKey: String {
    case isProductionEnvironment = "com.miaSample.isProductionEnvironment"
    case isChargingPaymentEnabled = "com.miaSample.isChargingPaymentEnabled"
    case handlingConsumerData = "com.miaSample.handlingConsumerData"
    case userProfileData = "com.miaSample.userProfileData"
    
    case testEnvironmentSecretKey = "com.miaSample.testEnvironmentSecretKey"
    case testCheckoutKey = "com.miaSample.testCheckoutKey"
    case productionCheckoutKey = "com.miaSample.productionCheckoutKey"
    case productionSecretKey = "com.miaSample.productionSecretKey"
    
    case testSubscriptions = "com.miaSample.testSubscriptions"
    case productionSubscriptions = "com.miaSample.productionSubscriptions"
}

@propertyWrapper
struct Persisted<T> {
    let key: String
    let defaultValue: T

    init(_ key: PersistanceKey, defaultValue: T) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return userDefaults.value(forKey: key) as? T ?? defaultValue
        }
        set(new) {
            defer { userDefaults.synchronize() }
            if let optionalValue = new as? OptionalType, optionalValue.isNil {
                userDefaults.removeObject(forKey: key)
                return
            }
            userDefaults.set(new, forKey: key)
        }
    }
}

protocol OptionalType {
    var isNil: Bool { get }
}

extension Optional: OptionalType {
    var isNil: Bool {
        switch self {
        case .none: return true
        case .some(_): return false
        }
    }
}

@propertyWrapper
struct PersistedArray<T> {
    let key: String
    let defaultValue: [T]

    init(_ key: PersistanceKey, defaultValue: [T]) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }

    var wrappedValue: [T] {
        get {
            guard let data = userDefaults.object(forKey: key) as? Data else {
                return []
            }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as! [T]
        }
        set(items) {
            defer { userDefaults.synchronize() }
            let data = NSKeyedArchiver.archivedData(withRootObject: items)
            userDefaults.set(data, forKey: key)
        }
    }
}

/// The internal underlying store.
/// Change this store when testing. Look below for `changeStore..` API.
private var userDefaults = UserDefaults(suiteName: "Mia-Sample")!

/// Change the underlying store to the given `suiteName`.
/// e.g. when testing to avoid side effects to the app storage.
func changeStorage(toSuiteNamed suiteName: String) {
    userDefaults = UserDefaults(suiteName: suiteName)!
}

/// Clean storage of given suite name.
func cleanStorage(_ suiteName: String = "Mia-Sample") {
    guard let store = UserDefaults(suiteName: suiteName) else { return }
    store.removePersistentDomain(forName: suiteName)
    store.synchronize()
}

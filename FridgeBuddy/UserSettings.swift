//
//  UserDefaultManager.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/27/24.
//

import Foundation

class UserSettings {
    
    static let shared = UserSettings()
    
    private init() {}
    
    var notifyAt: Date? {
        get {
            return UserDefaults.standard.object(forKey: Keys.NOTIFY_AT) as? Date
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.NOTIFY_AT)
        }
    }
    
    var notifyBefore: Int? {
        get {
            return UserDefaults.standard.integer(forKey: Keys.NOTIFY_BEFORE)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.NOTIFY_BEFORE)
        }
    }
    
    var notificationStatus: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: Keys.NOTIFICATION_STATUS)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.NOTIFICATION_STATUS)
        }
    }
    
//    let userDefaults = UserDefaults.standard
//    
//    func set(value: Any, key: String) {
//        userDefaults.setValue(value, forKey: key)
//        userDefaults.synchronize()
//    }
//    
//    func get(key: String) -> Any? {
//        if userDefaults.object(forKey: key) != nil {
//            return userDefaults.object(forKey: key)
//        } else {
//            return nil
//        }
//    }
}

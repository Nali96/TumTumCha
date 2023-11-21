//
//  UserDefaultController.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 03/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import Foundation

struct SettingsData: Codable {
    
    var invertAxis: Bool
    var gesture: ActionsType
    var showCounter: Bool
}

class UserDefaultSettings {
    
    private var userDefault: UserDefaults
    private let settingsKey = "Settings"
    
    init() {
        userDefault = UserDefaults.standard
    }
    
    func save(settingData: SettingsData) {
        
        let encodedValues = try! JSONEncoder().encode(settingData)
        userDefault.set(encodedValues, forKey: settingsKey)
        print("Saved Setting")
    }
    
    func retrieve() -> SettingsData {
        
        let data = userDefault.value(forKey: settingsKey)
        if data != nil {
            let decodedData = try! JSONDecoder().decode(SettingsData.self, from: data as! Data)
            return decodedData
        } else {
            return SettingsData(invertAxis: false, gesture: .multiTap, showCounter: true)
        }
    }
    
    func resetSettings() {
           userDefault.removeObject(forKey: settingsKey)
    }
}

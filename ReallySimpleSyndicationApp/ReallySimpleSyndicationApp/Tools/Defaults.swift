//
//  Defaults.swift
//  ReallySimpleSyndicationApp
//
//  Created by Viktor Krasilnikov on 24.10.22.
//

import Foundation

struct Defaults {
    static let store = UserDefaults(suiteName: AppKeys.storeId.rawValue)
    
    static func set(_ value: Any?, forKey: String) {
        store?.set(value, forKey: forKey)
        store?.synchronize()
    }
}

enum AppKeys: String {
    case storeId
    case url
}


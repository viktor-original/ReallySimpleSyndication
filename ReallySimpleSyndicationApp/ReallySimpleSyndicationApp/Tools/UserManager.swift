//
//  UserManager.swift
//  ReallySimpleSyndicationApp
//
//  Created by Viktor Krasilnikov on 24.10.22.
//

import Foundation

final class UserManager {
    
    static let shared = UserManager()
    
    var url: String? {
        get { return Defaults.store?.string(forKey: AppKeys.url.rawValue) }
        set {
            Defaults.set(newValue, forKey: AppKeys.url.rawValue)
        }
    }
}

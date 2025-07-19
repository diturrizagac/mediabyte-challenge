//
//  Bundle+Extensions.swift
//  MBChallenge
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import Foundation

extension Bundle {
    
    var guardianAPIBaseURL: String {
        return object(forInfoDictionaryKey: "GuardianAPIBaseURL") as? String ?? "https://content.guardianapis.com"
    }
    
    var guardianAPIKey: String {
        return object(forInfoDictionaryKey: "GuardianAPIKey") as? String ?? ""
    }
} 
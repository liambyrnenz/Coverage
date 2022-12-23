//
//  Set+Utilities.swift
//  CoverageCommon
//
//  Created by Liam on 23/12/22.
//

import Foundation

public extension Set where Element == String {
    
    var longest: String? {
        return self.max(by: { $0.count < $1.count })
    }
    
}

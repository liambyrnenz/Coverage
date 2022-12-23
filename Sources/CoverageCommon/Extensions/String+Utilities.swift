//
//  String+Utilities.swift
//  CoverageCommon
//
//  Created by Liam on 23/12/22.
//

import Foundation

extension String {
    
    public static var newline: String { "\n" }
    
    /// Formats the given value (assumed to be a double which is between 0 and 1) into a percentage with one decimal place.
    public static func formattedToStandardPercentage(_ value: Double) -> String {
        return "\(String(format: "%.1f", value * 100))%"
    }
    
}

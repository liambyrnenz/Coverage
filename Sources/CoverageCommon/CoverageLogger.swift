//
//  CoverageLogger.swift
//  CoverageCommon
//
//  Created by Liam on 23/12/22.
//

import CommandLineUtilities

/// A subclass of `CategoryLogger` that also adds options for suppressing certain categories.
public class CoverageLogger: CategoryLogger {
    
    public var shouldShowDebug: Bool = false
    public var quietModeEnabled: Bool = false
    
    public func write(message: String, category: LoggerCategory = .none) {
        // hide all non-essential output if quiet mode is enabled
        if quietModeEnabled, [.error, .output, .hint, .debug, .none].contains(category) == false {
            return
        }
        
        super.write(message: message, category: category, shouldShowDebug: shouldShowDebug)
    }
    
}

public let log = CoverageLogger()

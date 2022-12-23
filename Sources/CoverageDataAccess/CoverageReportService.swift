//
//  CoverageReportService.swift
//  CoverageDataAccess
//
//  Created by Liam on 23/12/22.
//

import CommandLineUtilities

/// An interface for accessing coverage data, just like a service in a network-connected application.
public protocol CoverageReportServiceProtocol {
    
    /// Get the raw list of available targets within the given result bundle as a JSON string.
    func availableTargets(inResultBundleAt resultBundlePath: String) -> String
    
    /// Get the raw coverage report for the given target within the given result bundle as a single JSON string.
    func rawCoverageReport(forTarget target: String, inResultBundleAt resultBundlePath: String) -> String
    
}

class CoverageReportService: CoverageReportServiceProtocol {
    
    func availableTargets(inResultBundleAt resultBundlePath: String) -> String {
        let viewTargetsCommand = "xcrun xccov view --report --only-targets --json \"\(resultBundlePath)\""
        let output = TerminalHelper.execute(viewTargetsCommand)
        return removeWarnings(from: output)
    }
    
    func rawCoverageReport(forTarget target: String, inResultBundleAt resultBundlePath: String) -> String {
        let viewReportCommand = "xcrun xccov view --report --files-for-target \"\(target)\" --json \"\(resultBundlePath)\""
        let output = TerminalHelper.execute(viewReportCommand, wait: false) // don't wait for process termination since this command doesn't seem to terminate...?
        return removeWarnings(from: output)
    }
    
    private func removeWarnings(from output: String) -> String {
        return output.components(separatedBy: .newlines).filter({ line in
            line.contains("xccov[") == false
        }).joined(separator: .newline)
    }
    
}

/*
 
 Example format for JSON target report:
 ---
 [
    {
        "coveredLines": 503,
        "lineCoverage": 0.53854389721627405,
        "name": "MyApplicationCommon.framework",
        "executableLines": 934,
        "buildProductPath": "\/Users\/Liam\/Library\/Developer\/Xcode\/DerivedData\/MyApplication-aabbccddeeffgghhiijjkkllmmnn\/Build\/Products\/Debug-iphonesimulator\/MyApplicationCommon.framework\/MyApplicationCommon"
    }
 ]
 
 Example format for JSON coverage report:
 ---
 [
   {
     "product": "\/Users\/liam\/Library\/Developer\/Xcode\/DerivedData\/MyApplication-aabbccddeeffgghhiijjkkllmmnn\/Build\/Products\/Debug-iphonesimulator\/MyApplication.app\/MyApplication",
     "files": [
       {
         "coveredLines": 3,
         "lineCoverage": 0.059999999999999998,
         "path": "\/Users\/Liam\/Developer\/my-application-ios\/MyApplication\/MyApplication\/Views\/TodoListView.swift",
         "name": "TodoListView.swift",
         "executableLines": 50
       }
     ]
   }
 ]
 
 */

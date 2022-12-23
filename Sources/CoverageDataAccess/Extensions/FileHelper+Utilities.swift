//
//  FileHelper+Utilities.swift
//  CoverageDataAccess
//
//  Created by Liam on 23/12/22.
//

import CommandLineUtilities

extension FileHelper {
    
    /// Get the path of the most recently created result bundle in the specified directory.
    ///
    /// - Parameter directory: full path to directory
    /// - Returns: path to most recent result bundle in directory
    public static func getLatestResultBundle(in directory: String) -> String {
        let latestResultBundleCommand = "find \(directory) -name \"*.xcresult\" -type d -print0 | xargs -0 ls -dt1 | head -1 | tr -d '\n'"
        return TerminalHelper.execute(latestResultBundleCommand)
    }
    
    // alternative command for getLatestResultBundle(in:)
    // explanation of this command:
    // - find finds and prints all directories, output is a single string delimited with nulls
    // - xargs takes that string and knows that it's null-delimited (this strategy helps make sure we support files with spaces in them) and calls the stat command for each line in the input string.
    // - stat prints the time and the name of each file
    // - sort sorts by name, and thus by time, ascending
    // - tail takes the last file, which is the latest
    // - awk replaces fields 1 through 5 with spaces, then prints everything after the 5th space, which is the full filename inc. spaces.
    // let latestResultBundleCommand = "find \(directory) -name \"*.xcresult*\" -type d -print0 | xargs -0 stat -f \"%m%t%Sm %N\" | sort -n | tail -1 | awk '{$1=\"\";$2=\"\";$3=\"\";$4=\"\";$5=\"\";print substr($0,6)}'"
    
    /// Write the generated report into a file. The file's name is based upon the last component of the given result bundle path.
    ///
    /// - Parameters:
    ///   - report: contents of the generated report
    ///   - resultBundlePath: original result bundle path used in the main script
    /// - Throws: `FileError` if writing failed
    /// - Returns: filename used for the report
    @discardableResult
    public static func writeReportToFile(_ report: String, resultBundlePath: String) throws -> String {
        guard let resultBundleName = resultBundlePath.split(separator: "/").last else {
            throw FileError.writingFailed(rawLog: nil)
        }
        let filename = String(resultBundleName).replacingOccurrences(of: ".xcresult", with: "-report.txt")
        
        try write(fileContents: report, into: filename)
        return filename
    }
    
}

//
//  CoverageReportLine.swift
//  CoverageDataAccess
//
//  Created by Liam on 23/12/22.
//

import CoverageCommon

/// An alias that allows for usage of the `CoverageReportLine` type in target report contexts, since an individual line
/// of a coverage report in this instance shows information for a target.
public typealias CoverageReportTarget = CoverageReportLine

/// An alias that allows for usage of the `CoverageReportLine` type in file report contexts, since an individual line
/// of a coverage report in this instance shows information for a file.
public typealias CoverageReportFile = CoverageReportLine

/// A structure that represents an individual line of a coverage report. This contains information
/// about some entity that has code coverage metrics, such as a file or target.
public struct CoverageReportLine: Codable {
    public let name: String
    public let lineCoverage: Double
    public let coveredLines: Int
    public let executableLines: Int
    public let path: String?
    public let buildProductPath: String?
    
    internal init(name: String, lineCoverage: Double, coveredLines: Int, executableLines: Int, path: String?, buildProductPath: String?) {
        self.name = name
        self.lineCoverage = lineCoverage
        self.coveredLines = coveredLines
        self.executableLines = executableLines
        self.path = path
        self.buildProductPath = buildProductPath
    }
    
    public func formattedLineCoverage() -> String {
        return .formattedToStandardPercentage(lineCoverage)
    }
}

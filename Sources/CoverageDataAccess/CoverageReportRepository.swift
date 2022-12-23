//
//  CoverageReportRepository.swift
//  CoverageDataAccess
//
//  Created by Liam on 23/12/22.
//

import Foundation
import CommandLineUtilities
import CoverageCommon

public enum CoverageRepositoryError: Error {
    case emptyReport
    
    var localizedDescription: String {
        switch self {
        case .emptyReport:
            return "no data found in report, cannot proceed"
        }
    }
}

/// Accessor for raw coverage report data; translates into usable DTOs.
public protocol CoverageReportRepositoryProtocol {
    
    /// Get the unmodified, structured list of all targets in the given result bundle.
    ///
    /// - Parameter resultBundlePath: filepath to the .xcresult file for the test build
    /// - Returns: a list of `CoverageReportTarget` structs representing each target
    func availableTargets(inResultBundleAt resultBundlePath: String) throws -> [CoverageReportTarget]
    
    /// Get the unmodified, structured coverage report for the given target within the given result bundle.
    ///
    /// - Parameters:
    ///   - target: name of the target exactly, e.g. "MyApplication.app"
    ///   - resultBundlePath: filepath to the .xcresult file for the test build
    /// - Returns: a `CoverageReport` struct representing the report
    func coverageReport(forTarget target: String, inResultBundleAt resultBundlePath: String) throws -> CoverageReport
    
}

public class CoverageReportRepository: CoverageReportRepositoryProtocol {
    
    private let service: CoverageReportServiceProtocol
    
    public init() {
        self.service = CoverageReportService()
    }
    
    internal init(service: CoverageReportServiceProtocol) {
        self.service = service
    }
    
    public func availableTargets(inResultBundleAt resultBundlePath: String) throws -> [CoverageReportTarget] {
        let rawReport = service.availableTargets(inResultBundleAt: resultBundlePath)
        let data: [CoverageReportLine] = try jsonObjects(from: rawReport)
        
        guard data.isEmpty == false else {
            throw CoverageRepositoryError.emptyReport
        }
        
        return data
    }
    
    public func coverageReport(forTarget target: String, inResultBundleAt resultBundlePath: String) throws -> CoverageReport {
        // get JSON representation of report from xccov
        let rawReport = service.rawCoverageReport(forTarget: target, inResultBundleAt: resultBundlePath)
        let data: [CoverageReport] = try jsonObjects(from: rawReport)
        
        guard let report = data.first else {
            throw CoverageRepositoryError.emptyReport
        }
        return report
    }
    
    private func jsonObjects<T: Decodable>(from rawStringData: String) throws -> T {
        log.write(message: rawStringData, category: .debug)
        return try JSONDecoder().decode(T.self, from: rawStringData.data(using: .utf8)!)
    }
    
}

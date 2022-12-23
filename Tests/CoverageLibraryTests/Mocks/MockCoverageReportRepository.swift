//
//  MockCoverageReportRepository.swift
//  CoverageLibraryTests
//
//  Created by Liam on 23/12/22.
//

@testable import CoverageDataAccess

class MockCoverageReportRepository: CoverageReportRepositoryProtocol {
    
    var mockTargets: [CoverageReportTarget] = []
    var mockReport: CoverageReport = .init(product: "", files: [])
    
    func availableTargets(inResultBundleAt resultBundlePath: String) throws -> [CoverageReportTarget] {
        return mockTargets
    }
    
    func coverageReport(forTarget target: String, inResultBundleAt resultBundlePath: String) throws -> CoverageReport {
        return mockReport
    }
    
}

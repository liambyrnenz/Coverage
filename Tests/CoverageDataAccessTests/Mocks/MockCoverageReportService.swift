//
//  MockCoverageReportService.swift
//  CoverageDataAccessTests
//
//  Created by Liam on 23/12/22.
//

import CoverageDataAccess

class MockCoverageReportService: CoverageReportServiceProtocol {
    
    var mockAvailableTargetsResponse: String = ""
    var mockRawCoverageReportResponse: String = ""
    
    func availableTargets(inResultBundleAt resultBundlePath: String) -> String {
        return mockAvailableTargetsResponse
    }
    
    func rawCoverageReport(forTarget target: String, inResultBundleAt resultBundlePath: String) -> String {
        return mockRawCoverageReportResponse
    }
    
}

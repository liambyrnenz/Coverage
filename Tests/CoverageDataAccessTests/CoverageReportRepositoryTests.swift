//
//  CoverageReportRepositoryTests
//  CoverageDataAccessTests
//
//  Created by Liam on 23/12/22.
//

import XCTest
@testable import CoverageDataAccess

class CoverageReportRepositoryTests: XCTestCase {
    
    var mockService: MockCoverageReportService!
    
    override func setUp() {
        self.mockService = MockCoverageReportService()
    }
    
}

// MARK: Valid data

extension CoverageReportRepositoryTests {
    
    func testValidAvailableTargets() {
        let repository = CoverageReportRepository(service: mockService)
        mockService.mockAvailableTargetsResponse = """
        [
            {
                "coveredLines": 100,
                "lineCoverage": 0.7512345,
                "name": "MyTarget.app",
                "executableLines": 133,
                "buildProductPath": "X"
            },
            {
                "coveredLines": 25,
                "lineCoverage": 0.25,
                "name": "MyTargetTests.framework",
                "executableLines": 100,
                "buildProductPath": "X"
            },
            {
                "coveredLines": 4234,
                "lineCoverage": 0.117892,
                "name": "SomeFramework.framework",
                "executableLines": 35914,
                "buildProductPath": "X"
            }
        ]
        """
        
        do {
            let targets = try repository.availableTargets(inResultBundleAt: "") // path not needed for mock
            
            XCTAssertEqual(targets.count, 3)
            
            XCTAssertEqual(targets[0].coveredLines, 100)
            XCTAssertEqual(targets[0].lineCoverage, 0.7512345)
            XCTAssertEqual(targets[0].name, "MyTarget.app")
            XCTAssertEqual(targets[0].executableLines, 133)
            
            XCTAssertEqual(targets[1].coveredLines, 25)
            XCTAssertEqual(targets[1].lineCoverage, 0.25)
            XCTAssertEqual(targets[1].name, "MyTargetTests.framework")
            XCTAssertEqual(targets[1].executableLines, 100)
            
            XCTAssertEqual(targets[2].coveredLines, 4234)
            XCTAssertEqual(targets[2].lineCoverage, 0.117892)
            XCTAssertEqual(targets[2].name, "SomeFramework.framework")
            XCTAssertEqual(targets[2].executableLines, 35914)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testValidRawCoverageReport() {
        let repository = CoverageReportRepository(service: mockService)
        mockService.mockRawCoverageReportResponse = """
        [
            {
                "product": "",
                "files": [
                    {
                        "coveredLines": 58,
                        "lineCoverage": 0.1847133758,
                        "path": "",
                        "name": "File1.swift",
                        "executableLines": 314
                    },
                    {
                        "coveredLines": 13,
                        "lineCoverage": 0.6842105263,
                        "path": "",
                        "name": "File2.swift",
                        "executableLines": 19
                    },
                    {
                        "coveredLines": 400,
                        "lineCoverage": 1,
                        "path": "",
                        "name": "File3.swift",
                        "executableLines": 400
                    },
                    {
                        "coveredLines": 0,
                        "lineCoverage": 0,
                        "path": "",
                        "name": "File4.swift",
                        "executableLines": 27
                    },
                    {
                        "coveredLines": 388,
                        "lineCoverage": 0.8584070796,
                        "path": "",
                        "name": "File5.swift",
                        "executableLines": 452
                    }
                ]
            }
        ]
        """
        
        do {
            let report = try repository.coverageReport(forTarget: "", inResultBundleAt: "")
            let files = report.files
            
            XCTAssertEqual(files.count, 5)
            
            XCTAssertEqual(files[0].coveredLines, 58)
            XCTAssertEqual(files[0].lineCoverage, 0.1847133758)
            XCTAssertEqual(files[0].name, "File1.swift")
            XCTAssertEqual(files[0].executableLines, 314)
            
            XCTAssertEqual(files[1].coveredLines, 13)
            XCTAssertEqual(files[1].lineCoverage, 0.6842105263)
            XCTAssertEqual(files[1].name, "File2.swift")
            XCTAssertEqual(files[1].executableLines, 19)
            
            XCTAssertEqual(files[2].coveredLines, 400)
            XCTAssertEqual(files[2].lineCoverage, 1)
            XCTAssertEqual(files[2].name, "File3.swift")
            XCTAssertEqual(files[2].executableLines, 400)
            
            XCTAssertEqual(files[3].coveredLines, 0)
            XCTAssertEqual(files[3].lineCoverage, 0)
            XCTAssertEqual(files[3].name, "File4.swift")
            XCTAssertEqual(files[3].executableLines, 27)
            
            XCTAssertEqual(files[4].coveredLines, 388)
            XCTAssertEqual(files[4].lineCoverage, 0.8584070796)
            XCTAssertEqual(files[4].name, "File5.swift")
            XCTAssertEqual(files[4].executableLines, 452)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}

// MARK: Invalid data

extension CoverageReportRepositoryTests {
    
    func testEmptyAvailableTargets() {
        let repository = CoverageReportRepository(service: mockService)
        mockService.mockAvailableTargetsResponse = "[]"
        
        XCTAssertThrowsError(try repository.availableTargets(inResultBundleAt: "")) { error in
            switch error {
            case CoverageRepositoryError.emptyReport:
                XCTAssertEqual((error as! CoverageRepositoryError).localizedDescription, "no data found in report, cannot proceed")
            default:
                XCTFail("Error was of unexpected type \(error.self)")
            }
        }
    }
    
    func testEmptyRawCoverageReport() {
        let repository = CoverageReportRepository(service: mockService)
        mockService.mockRawCoverageReportResponse = "[]"
        
        XCTAssertThrowsError(try repository.coverageReport(forTarget: "", inResultBundleAt: "")) { error in
            switch error {
            case CoverageRepositoryError.emptyReport:
                XCTAssertEqual((error as! CoverageRepositoryError).localizedDescription, "no data found in report, cannot proceed")
            default:
                XCTFail("Error was of unexpected type \(error.self)")
            }
        }
    }
    
}

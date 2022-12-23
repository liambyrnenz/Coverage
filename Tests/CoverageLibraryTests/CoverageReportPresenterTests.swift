//
//  CoverageReportPresenterTests.swift
//  CoverageLibraryTests
//
//  Created by Liam on 23/12/22.
//

import XCTest
@testable import CoverageLibrary
@testable import CoverageDataAccess

class CoverageReportPresenterTests: XCTestCase {
    
    var mockRepository: MockCoverageReportRepository!
    var optionsHelper: OptionsHelper!
    
    override func setUp() {
        mockRepository = MockCoverageReportRepository()
        optionsHelper = OptionsHelper()
    }
    
    func createPresenter() -> CoverageReportPresenter {
        return CoverageReportPresenter(repository: mockRepository, optionsHelper: optionsHelper, resultBundlePath: "")
    }
    
}

// MARK: Available targets

extension CoverageReportPresenterTests {
    
    func testBaseAvailableTargetsReport() throws {
        mockRepository.mockTargets = [
            target(name: "MyTarget.app", coveredLines: 100, executableLines: 133),
            target(name: "MyTargetTests.framework", coveredLines: 25, executableLines: 100),
            target(name: "SomeFramework.framework", coveredLines: 4234, executableLines: 35914)
        ]
        let presenter = createPresenter()
        
        let report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)
            MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)
            SomeFramework.framework          [==                  ]     11.8% (4234/35914 lines)

            ------------------------------------------------------------------------------------
            3 targets, 36147 lines, 12.1% total coverage

            """)
    }
    
    func testFilteredAvailableTargetsReport() throws {
        mockRepository.mockTargets = [
            target(name: "MyTarget.app", coveredLines: 100, executableLines: 133),
            target(name: "MyTargetTests.framework", coveredLines: 25, executableLines: 100),
            target(name: "SomeFramework.framework", coveredLines: 4234, executableLines: 35914)
        ]
        let presenter = createPresenter()
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-f", "MyTarget"])
        
        let report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)
            MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)

            ---------------------------------------------------------------------------------
            2 targets, 233 lines, 53.6% total coverage

            """)
    }
    
    func testFilteredAndExcludedAvailableTargetsReport() throws {
        mockRepository.mockTargets = [
            target(name: "MyTarget.app", coveredLines: 100, executableLines: 133),
            target(name: "MyTargetTests.framework", coveredLines: 25, executableLines: 100),
            target(name: "SomeFramework.framework", coveredLines: 4234, executableLines: 35914)
        ]
        let presenter = createPresenter()
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-f", "MyTarget", "-x", ".framework"])
        
        let report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)

            ---------------------------------------------------------------------------------
            1 targets, 133 lines, 75.2% total coverage

            """)
    }
    
    func testSortedAvailableTargetsReport() throws {
        mockRepository.mockTargets = [
            target(name: "MyTarget.app", coveredLines: 100, executableLines: 133),
            target(name: "MyTargetTests.framework", coveredLines: 25, executableLines: 100),
            target(name: "SomeFramework.framework", coveredLines: 4234, executableLines: 35914)
        ]
        let presenter = createPresenter()
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "alphabetical"])
        
        var report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)
            MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)
            SomeFramework.framework          [==                  ]     11.8% (4234/35914 lines)

            ------------------------------------------------------------------------------------
            3 targets, 36147 lines, 12.1% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "highestCoverage"])
        
        report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)
            MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)
            SomeFramework.framework          [==                  ]     11.8% (4234/35914 lines)

            ------------------------------------------------------------------------------------
            3 targets, 36147 lines, 12.1% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "lowestCoverage"])
        
        report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            SomeFramework.framework          [==                  ]     11.8% (4234/35914 lines)
            MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)

            ------------------------------------------------------------------------------------
            3 targets, 36147 lines, 12.1% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "mostLines"])
        
        report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            SomeFramework.framework          [==                  ]     11.8% (4234/35914 lines)
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)
            MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)

            ------------------------------------------------------------------------------------
            3 targets, 36147 lines, 12.1% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "biggestGap"])
        
        report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            SomeFramework.framework          [==                  ]     11.8% (4234/35914 lines)
            MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)

            ------------------------------------------------------------------------------------
            3 targets, 36147 lines, 12.1% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "smallestGap"])
        
        report = try presenter.availableTargets()
        XCTAssertEqual(report, """
            MyTarget.app                     [===============     ]     75.2% (100/133 lines)
            MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)
            SomeFramework.framework          [==                  ]     11.8% (4234/35914 lines)

            ------------------------------------------------------------------------------------
            3 targets, 36147 lines, 12.1% total coverage

            """)
    }
    
    func testRouletteInAvailableTargetsReport() throws {
        mockRepository.mockTargets = [
            target(name: "MyTarget.app", coveredLines: 100, executableLines: 133),
            target(name: "MyTargetTests.framework", coveredLines: 25, executableLines: 100),
            target(name: "SomeFramework.framework", coveredLines: 4234, executableLines: 35914)
        ]
        let presenter = createPresenter()
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-r"])
        
        let report = try presenter.availableTargets()
        XCTAssertTrue([
            "MyTarget.app                     [===============     ]     75.2% (100/133 lines)",
            "MyTargetTests.framework          [=====               ]     25.0% (25/100 lines)",
            "SomeFramework.framework          [==                  ]     11.8% (4234/35914 lines)"
        ].contains(report.trimmingCharacters(in: .whitespacesAndNewlines)))
    }
    
}

// MARK: Coverage report

extension CoverageReportPresenterTests {
    
    func testBaseCoverageReport() throws {
        mockRepository.mockReport = CoverageReport(product: "", files: [
            file(name: "File1.swift", coveredLines: 58, executableLines: 314),
            file(name: "File2.swift", coveredLines: 13, executableLines: 19),
            file(name: "File3.swift", coveredLines: 400, executableLines: 400),
            file(name: "File4.swift", coveredLines: 0, executableLines: 27),
            file(name: "File5.swift", coveredLines: 388, executableLines: 452)
        ])
        let presenter = createPresenter()
        
        let report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            File1.swift          [===                 ]     18.5% (58/314 lines)
            File2.swift          [=============       ]     68.4% (13/19 lines)
            File3.swift          [====================]     100.0% (400/400 lines)
            File4.swift          [                    ]     0.0% (0/27 lines)
            File5.swift          [=================   ]     85.8% (388/452 lines)

            ----------------------------------------------------------------------
            5 files, 1212 lines, 70.9% total coverage

            """)
    }
    
    func testFilteredCoverageReport() throws {
        mockRepository.mockReport = CoverageReport(product: "", files: [
            file(name: "AView.swift", coveredLines: 58, executableLines: 314),
            file(name: "APresenter.swift", coveredLines: 13, executableLines: 19),
            file(name: "BView.swift", coveredLines: 400, executableLines: 400),
            file(name: "BPresenter.swift", coveredLines: 0, executableLines: 27),
            file(name: "Service.swift", coveredLines: 388, executableLines: 452)
        ])
        let presenter = createPresenter()
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-f", "Presenter"])
        
        let report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            APresenter.swift          [=============       ]     68.4% (13/19 lines)
            BPresenter.swift          [                    ]     0.0% (0/27 lines)

            ------------------------------------------------------------------------
            2 files, 46 lines, 28.3% total coverage

            """)
    }
    
    func testFilteredAndExcludedCoverageReport() throws {
        mockRepository.mockReport = CoverageReport(product: "", files: [
            file(name: "AView.swift", coveredLines: 58, executableLines: 314),
            file(name: "APresenter.swift", coveredLines: 13, executableLines: 19),
            file(name: "BView.swift", coveredLines: 400, executableLines: 400),
            file(name: "BPresenter.swift", coveredLines: 0, executableLines: 27),
            file(name: "Service.swift", coveredLines: 388, executableLines: 452)
        ])
        let presenter = createPresenter()
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-x", "Service", "-f", "View"])
        
        let report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            AView.swift               [===                 ]     18.5% (58/314 lines)
            BView.swift               [====================]     100.0% (400/400 lines)

            ---------------------------------------------------------------------------
            2 files, 714 lines, 64.1% total coverage

            """)
    }
    
    func testSortedCoverageReport() throws {
        mockRepository.mockReport = CoverageReport(product: "", files: [
            file(name: "AView.swift", coveredLines: 58, executableLines: 314),
            file(name: "APresenter.swift", coveredLines: 13, executableLines: 19),
            file(name: "BView.swift", coveredLines: 400, executableLines: 400),
            file(name: "BPresenter.swift", coveredLines: 0, executableLines: 27),
            file(name: "Repository.swift", coveredLines: 201, executableLines: 201),
            file(name: "Service.swift", coveredLines: 388, executableLines: 452)
        ])
        let presenter = createPresenter()
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "alphabetical"])
        
        var report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            APresenter.swift          [=============       ]     68.4% (13/19 lines)
            AView.swift               [===                 ]     18.5% (58/314 lines)
            BPresenter.swift          [                    ]     0.0% (0/27 lines)
            BView.swift               [====================]     100.0% (400/400 lines)
            Repository.swift          [====================]     100.0% (201/201 lines)
            Service.swift             [=================   ]     85.8% (388/452 lines)

            ---------------------------------------------------------------------------
            6 files, 1413 lines, 75.0% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "highestCoverage"])
        
        report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            BView.swift               [====================]     100.0% (400/400 lines)
            Repository.swift          [====================]     100.0% (201/201 lines)
            Service.swift             [=================   ]     85.8% (388/452 lines)
            APresenter.swift          [=============       ]     68.4% (13/19 lines)
            AView.swift               [===                 ]     18.5% (58/314 lines)
            BPresenter.swift          [                    ]     0.0% (0/27 lines)

            ---------------------------------------------------------------------------
            6 files, 1413 lines, 75.0% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "lowestCoverage"])
        
        report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            BPresenter.swift          [                    ]     0.0% (0/27 lines)
            AView.swift               [===                 ]     18.5% (58/314 lines)
            APresenter.swift          [=============       ]     68.4% (13/19 lines)
            Service.swift             [=================   ]     85.8% (388/452 lines)
            BView.swift               [====================]     100.0% (400/400 lines)
            Repository.swift          [====================]     100.0% (201/201 lines)

            ---------------------------------------------------------------------------
            6 files, 1413 lines, 75.0% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "mostLines"])
        
        report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            Service.swift             [=================   ]     85.8% (388/452 lines)
            BView.swift               [====================]     100.0% (400/400 lines)
            AView.swift               [===                 ]     18.5% (58/314 lines)
            Repository.swift          [====================]     100.0% (201/201 lines)
            BPresenter.swift          [                    ]     0.0% (0/27 lines)
            APresenter.swift          [=============       ]     68.4% (13/19 lines)

            ---------------------------------------------------------------------------
            6 files, 1413 lines, 75.0% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "biggestGap"])
        
        report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            AView.swift               [===                 ]     18.5% (58/314 lines)
            Service.swift             [=================   ]     85.8% (388/452 lines)
            BPresenter.swift          [                    ]     0.0% (0/27 lines)
            APresenter.swift          [=============       ]     68.4% (13/19 lines)
            BView.swift               [====================]     100.0% (400/400 lines)
            Repository.swift          [====================]     100.0% (201/201 lines)

            ---------------------------------------------------------------------------
            6 files, 1413 lines, 75.0% total coverage

            """)
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "smallestGap"])
        
        report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertEqual(report, """
            APresenter.swift          [=============       ]     68.4% (13/19 lines)
            BPresenter.swift          [                    ]     0.0% (0/27 lines)
            Service.swift             [=================   ]     85.8% (388/452 lines)
            AView.swift               [===                 ]     18.5% (58/314 lines)

            --------------------------------------------------------------------------
            4 files, 812 lines, 56.5% total coverage

            """)
    }
    
    func testRouletteInCoverageReport() throws {        
        mockRepository.mockReport = CoverageReport(product: "", files: [
            file(name: "File1.swift", coveredLines: 58, executableLines: 314),
            file(name: "File2.swift", coveredLines: 13, executableLines: 19),
            file(name: "File3.swift", coveredLines: 400, executableLines: 400),
            file(name: "File4.swift", coveredLines: 0, executableLines: 27),
            file(name: "File5.swift", coveredLines: 388, executableLines: 452)
        ])
        let presenter = createPresenter()
        
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-r"])
        
        let report = try presenter.coverageReport(target: "") // target is irrelevant
        XCTAssertTrue([
            "File1.swift          [===                 ]     18.5% (58/314 lines)",
            "File2.swift          [=============       ]     68.4% (13/19 lines)",
            "File3.swift          [====================]     100.0% (400/400 lines)",
            "File4.swift          [                    ]     0.0% (0/27 lines)",
            "File5.swift          [=================   ]     85.8% (388/452 lines)"
        ].contains(report.trimmingCharacters(in: .whitespacesAndNewlines)))
    }
    
}

// MARK: Utilities

extension CoverageReportPresenterTests {
    
    private func target(name: String, coveredLines: Int, executableLines: Int) -> CoverageReportTarget {
        return CoverageReportTarget(name: name, lineCoverage: Double(coveredLines) / Double(executableLines),
                                    coveredLines: coveredLines, executableLines: executableLines,
                                    path: nil, buildProductPath: "X")
    }
    
    private func file(name: String, coveredLines: Int, executableLines: Int) -> CoverageReportFile {
        return CoverageReportFile(name: name, lineCoverage: Double(coveredLines) / Double(executableLines),
                                  coveredLines: coveredLines, executableLines: executableLines,
                                  path: "", buildProductPath: nil)
    }
    
}

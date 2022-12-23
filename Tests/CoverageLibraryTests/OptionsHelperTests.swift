//
//  OptionsHelperTests.swift
//  CoverageLibraryTests
//
//  Created by Liam on 23/12/22.
//

import XCTest
import CommandLineUtilities
@testable import CoverageLibrary

class OptionsHelperTests: XCTestCase {
    
    var optionsHelper: OptionsHelper!
    
    override func setUp() {
        optionsHelper = OptionsHelper()
    }
    
}

// MARK: Help option

extension OptionsHelperTests {
    
    func testHelpOptionShort() throws {
        _ = try optionsHelper.evaluate(["-h"])
        XCTAssertTrue(optionsHelper.helpOption)
    }
    
    func testHelpOptionLong() throws {
        _ = try optionsHelper.evaluate(["--help"])
        XCTAssertTrue(optionsHelper.helpOption)
    }
    
    func testHelpOptionRemovesAllOptions() throws {
        let arguments = try optionsHelper.evaluate(["-h", "-q", "-l"])
        XCTAssertEqual(arguments.count, 0)
    }
    
    func testHelpOptionNotAllowingArguments() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["-h", "AnArgument"]))
    }
    
}

// MARK: Quiet option

extension OptionsHelperTests {
    
    func testQuietOptionShort() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-q"])
        XCTAssertTrue(optionsHelper.quietModeOption)
    }
    
    func testQuietOptionLong() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "--quiet"])
        XCTAssertTrue(optionsHelper.quietModeOption)
    }

}

// MARK: View targets option

extension OptionsHelperTests {
    
    func testViewTargetsOptionShort() throws {
        _ = try optionsHelper.evaluate(["-v", "ResultBundlePath"])
        XCTAssertTrue(optionsHelper.viewTargetsOption)
    }
    
    func testViewTargetsOptionLong() throws {
        _ = try optionsHelper.evaluate(["--view-targets", "ResultBundlePath"])
        XCTAssertTrue(optionsHelper.viewTargetsOption)
    }
    
    func testViewTargetsOptionRequiresOneArgument() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["-v"]))
        XCTAssertThrowsError(try optionsHelper.evaluate(["-v", "ArgumentOne", "ArgumentTwo"]))
        XCTAssertThrowsError(try optionsHelper.evaluate(["-v", "-l", "ArgumentOne", "ArgumentTwo"]))
    }
    
    func testViewTargetsOptionWithLatestOption() throws {
        _ = try optionsHelper.evaluate(["-v", "-l", "ResultBundleDirectory"])
        XCTAssertEqual(optionsHelper.latestInDirectoryOption, "ResultBundleDirectory")
    }
    
}

// MARK: Latest in directory option

extension OptionsHelperTests {
    
    func testLatestInDirectoryOptionShort() throws {
        _ = try optionsHelper.evaluate(["Target", "-l", "ResultBundleDirectory"])
        XCTAssertEqual(optionsHelper.latestInDirectoryOption, "ResultBundleDirectory")
    }
    
    func testLatestInDirectoryOptionLong() throws {
        _ = try optionsHelper.evaluate(["Target", "--latest", "ResultBundleDirectory"])
        XCTAssertEqual(optionsHelper.latestInDirectoryOption, "ResultBundleDirectory")
    }
    
    func testLatestInDirectoryOptionRequiresArgument() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["-l"]))
    }
    
}

// MARK: Filter option

extension OptionsHelperTests {
    
    func testFilterOptionShort() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-f", "Filter1"])
        XCTAssertEqual(optionsHelper.filterOption, ["Filter1"])
    }
    
    func testFilterOptionLong() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "--filter", "Filter1"])
        XCTAssertEqual(optionsHelper.filterOption, ["Filter1"])
    }
    
    func testFilterOptionRequiresArgument() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-f"]))
    }
    
    func testMultipleFilters() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-f", "Filter1,Filter2,Filter3"])
        XCTAssertEqual(optionsHelper.filterOption, ["Filter1", "Filter2", "Filter3"])
    }
    
    func testFilterOptionAppearingBeforeExclude() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-f", "Filter1", "-x", "Exclude1"])
        XCTAssertEqual(optionsHelper.filterAppearedBeforeExclude, true)
    }
    
    func testFilterOptionAppearingAfterExclude() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-x", "Exclude1", "-f", "Filter1"])
        XCTAssertEqual(optionsHelper.filterAppearedBeforeExclude, false)
    }
    
    func testFilterOptionAppearingWithNoExclude() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-f", "Filter1"])
        XCTAssertEqual(optionsHelper.filterAppearedBeforeExclude, nil)
    }
    
}

// MARK: Sort option

extension OptionsHelperTests {
    
    func testSortOptionShort() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "alphabetical"])
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
    }
    
    func testSortOptionLong() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "--sorted", "alphabetical"])
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
    }
    
    func testSortOptionRequiresArgument() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s"]))
    }
    
    func testSortOptionConversions() {
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "alphabetical"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "highestCoverage"]))
        XCTAssertEqual(optionsHelper.sortOption, .highestCoverage)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "lowestCoverage"]))
        XCTAssertEqual(optionsHelper.sortOption, .lowestCoverage)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "mostLines"]))
        XCTAssertEqual(optionsHelper.sortOption, .mostLines)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "biggestGap"]))
        XCTAssertEqual(optionsHelper.sortOption, .biggestGap)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "smallestGap"]))
        XCTAssertEqual(optionsHelper.sortOption, .smallestGap)
    }
    
    func testSortOptionWithMisspelledArgument() {
        optionsHelper = OptionsHelper() // reset
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "alphbetical"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "highestcoverage"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "lowestcoverage"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "mostlines"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "biggestgap"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "smallestgap"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
    }
    
    func testSortOptionIndexArguments() {
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "0"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "1"]))
        XCTAssertEqual(optionsHelper.sortOption, .highestCoverage)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "2"]))
        XCTAssertEqual(optionsHelper.sortOption, .lowestCoverage)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "3"]))
        XCTAssertEqual(optionsHelper.sortOption, .mostLines)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "4"]))
        XCTAssertEqual(optionsHelper.sortOption, .biggestGap)
        
        optionsHelper = OptionsHelper() // reset
        XCTAssertNoThrow(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "5"]))
        XCTAssertEqual(optionsHelper.sortOption, .smallestGap)
    }
    
    func testSortOptionIndexArgumentOutOfRange() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-s", "6"]))
        XCTAssertEqual(optionsHelper.sortOption, .alphabetical)
    }
    
}

// MARK: Exclude option

extension OptionsHelperTests {
    
    func testExcludeOptionShort() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-x", "Exclude1"])
        XCTAssertEqual(optionsHelper.excludeOption, ["Exclude1"])
    }
    
    func testExcludeOptionLong() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "--exclude", "Exclude1"])
        XCTAssertEqual(optionsHelper.excludeOption, ["Exclude1"])
    }
    
    func testExcludeOptionRequiresArgument() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-x"]))
    }
    
    func testMultipleExclusions() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-x", "Exclude1,Exclude2,Exclude3"])
        XCTAssertEqual(optionsHelper.excludeOption, ["Exclude1", "Exclude2", "Exclude3"])
    }
    
}

// MARK: Roulette option

extension OptionsHelperTests {
    
    func testRouletteOptionShort() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-r"])
        XCTAssertTrue(optionsHelper.rouletteOption)
    }
    
    func testRouletteOptionLong() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "--roulette"])
        XCTAssertTrue(optionsHelper.rouletteOption)
    }
    
}

// MARK: Write option

extension OptionsHelperTests {
    
    func testWriteOptionShort() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-w"])
        XCTAssertTrue(optionsHelper.writeOption)
    }
    
    func testWriteOptionLong() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "--write"])
        XCTAssertTrue(optionsHelper.writeOption)
    }
    
}

// MARK: Debug option

extension OptionsHelperTests {
    
    func testDebugOptionShort() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "-d"])
        XCTAssertTrue(optionsHelper.debugOption)
    }
    
    func testDebugOptionLong() throws {
        _ = try optionsHelper.evaluate(["Target", "ResultBundlePath.xcresult", "--debug"])
        XCTAssertTrue(optionsHelper.debugOption)
    }
    
}

// MARK: Base arguments

extension OptionsHelperTests {
    
    func testLatestInDirectoryWithTooManyArguments() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["-l", "ResultBundleDirectory", "AnArgument", "AnotherArgument"]))
    }
    
    func testNotEnoughBaseArguments() {
        XCTAssertThrowsError(try optionsHelper.evaluate([]))
    }
    
    func testIncorrectResultBundleType() {
        XCTAssertThrowsError(try optionsHelper.evaluate(["Target", "ResultBundlePath.xcarchive"]))
    }
    
}

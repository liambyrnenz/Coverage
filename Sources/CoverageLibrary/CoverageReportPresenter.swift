//
//  CoverageReportPresenter.swift
//  CoverageLibrary
//
//  Created by Liam on 23/12/22.
//

import CoverageDataAccess

/// An object that talks to the repository and configures the data it gets back to be used in report presentation.
public class CoverageReportPresenter {
    
    private enum ReportType: String {
        case target
        case file
    }
    
    private let repository: CoverageReportRepositoryProtocol
    private let optionsHelper: OptionsHelper
    
    private let resultBundlePath: String
    
    /// - Parameters:
    ///   - repository: an instance of `CoverageReportRepositoryProtocol` to facilitate data access
    ///   - optionsHelper: an instance of `OptionsHelper` to facilitate report formatting based on provided options
    ///   - resultBundlePath: absolute path to the result bundle to be used for report generation (this must always exist)
    public init(repository: CoverageReportRepositoryProtocol = CoverageReportRepository(), optionsHelper: OptionsHelper = .shared, resultBundlePath: String) {
        self.repository = repository
        self.optionsHelper = optionsHelper
        self.resultBundlePath = resultBundlePath
    }
    
    /// Generate a target report that shows the list of available targets and their overall coverage values.
    ///
    /// - Throws: errors from the repository to be handled at the main script level
    /// - Returns: string that contains the textual target report
    public func availableTargets() throws -> String {
        let targets = try repository.availableTargets(inResultBundleAt: resultBundlePath)
        return generateReport(from: targets, footerReportLineType: .target)
    }
    
    /// Generate a coverage report for the given target inside the pre-specified result bundle and create a textual, presentable form
    /// to display.
    ///
    /// - Parameter target: target: specified target to produce coverage report for
    /// - Throws: errors from the repository to be handled at the main script level
    /// - Returns: string that contains the textual coverage report
    public func coverageReport(target: String) throws -> String {
        let report = try repository.coverageReport(forTarget: target, inResultBundleAt: resultBundlePath)
        return generateReport(from: report.files, footerReportLineType: .file)
    }
    
}

// MARK: Report creation

extension CoverageReportPresenter {
    
    /// - Parameters:
    ///   - lines: line models from data access to convert to written report lines
    ///   - footerReportLineType: type of each line (for the footer report to generate correctly)
    private func generateReport(from lines: [CoverageReportLine], footerReportLineType: ReportType) -> String {
        var output = ""
        
        // determine the width of the name column by getting the longest file/target name and adding some padding
        let nameColumnWidth = longestNameCount(in: lines) + 10
        
        // process the report's files/targets by filtering and sorting, based on the provided options
        // see the OptionsHelper documentation for more info on the filter/exclude order
        var processedLines = lines
        if optionsHelper.filterAppearedBeforeExclude == true {
            processedLines = processedLines.filter(performFilter).filter(performExclusion)
        } else {
            processedLines = processedLines.filter(performExclusion).filter(performFilter)
        }
        processedLines = processedLines.sorted(by: optionsHelper.sortOption.comparator())
        
        // special case: filter out 100% covered files/targets if we are wanting lines with the smallest distance to 100% at the top
        if optionsHelper.sortOption == .smallestGap {
            processedLines = processedLines.filter { $0.coveredLines != $0.executableLines }
        }
        
        // set up storage for footer information to be added to over the report generation loop
        var totalCoveredLines: Double = 0
        var totalExecutableLines: Double = 0
        
        // if roulette mode is enabled, put a single random non-100% line into the report and end it there
        if optionsHelper.rouletteOption == true, let randomLine = processedLines.filter({ $0.coveredLines != $0.executableLines }).randomElement() {
            output.append(convertToReportLine(randomLine, nameColumnWidth: nameColumnWidth))
            return output
        }
        
        for line in processedLines {
            output.append(convertToReportLine(line, nameColumnWidth: nameColumnWidth))
            
            totalCoveredLines += Double(line.coveredLines)
            totalExecutableLines += Double(line.executableLines)
        }
        
        // add footer with overall coverage metrics
        let longestLineCount = longestReportLineCount(in: output.components(separatedBy: .newlines))
        output += reportFooter(longestLineCount: longestLineCount,
                               totalLinesCount: processedLines.count,
                               lineType: footerReportLineType,
                               totalCoveredLines: totalCoveredLines,
                               totalExecutableLines: totalExecutableLines)
        
        return output
    }
    
    private func convertToReportLine(_ line: CoverageReportLine, nameColumnWidth: Int) -> String {
        var output = ""
        
        // add the name and remaining space to fill the column
        output.append(reportLineName(from: line, inColumnWithWidth: nameColumnWidth))
        
        // add bar to help visualise relative coverage
        output.append(reportCoverageBar(from: line))
        
        // add coverage info to same line
        output.append(reportCoverageMetrics(from: line))
        
        // end line
        output.append(.newline)
        
        return output
    }
    
    private func performFilter(_ file: CoverageReportFile) -> Bool {
        let filters = optionsHelper.filterOption
        return filters.allSatisfy({ file.name.contains($0) }) // keep this file in if its name contains all specified tokens
    }
    
    private func performExclusion(_ file: CoverageReportFile) -> Bool {
        let exclusions = optionsHelper.excludeOption
        return exclusions.contains(where: { file.name.contains($0) }) == false // keep this file only if it contains none of the specified tokens
    }
    
}
    
// MARK: Report line creation

extension CoverageReportPresenter {
    
    private func reportLineName(from line: CoverageReportLine, inColumnWithWidth columnWidth: Int) -> String {
        return line.name + spaces(columnWidth - line.name.count)
    }
    
    private func reportCoverageMetrics(from line: CoverageReportLine) -> String {
        return "\(line.formattedLineCoverage()) (\(line.coveredLines)/\(line.executableLines) lines)"
    }
    
    private func reportCoverageBar(from line: CoverageReportLine) -> String {
        let maxBars: Double = 20 // each bar represents 5% of coverage
        var output = ""
        
        let numberOfBars: Int = Int(line.lineCoverage * maxBars) // coverage is <= 1 so we use proportions
        
        output.append("[") // encapsulate bars in brackets so files with no coverage can still be visually compared
        let bars = String(repeating: "=", count: numberOfBars)
        output.append(bars)
        output.append(spaces(Int(maxBars) - bars.count))
        output.append("]" + spaces(5)) // add some padding too
        
        return output
    }
    
    private func reportFooter(longestLineCount: Int, totalLinesCount: Int, lineType: ReportType, totalCoveredLines: Double, totalExecutableLines: Double) -> String {
        return .newline + String(repeating: "-", count: longestLineCount) + .newline +
            "\(totalLinesCount) \(lineType.rawValue)s, \(Int(totalExecutableLines)) lines, " +
            "\(String.formattedToStandardPercentage(totalCoveredLines / totalExecutableLines)) total coverage" + .newline
    }
    
}

// MARK: Formatting utilities

extension CoverageReportPresenter {
    
    // These utilities assume that the given arrays are never empty; there are checks done at the data layer
    // that should guarantee this.
    
    private func longestNameCount(in lines: [CoverageReportLine]) -> Int {
        return lines.map(\.name.count).max()!
    }
    
    private func longestReportLineCount(in lines: [String]) -> Int {
        return lines.map(\.count).max()!
    }
    
    private func spaces(_ count: Int) -> String {
        return String(repeating: " ", count: count)
    }
    
}

//
//  CoverageReportFileSortOption.swift
//  CoverageLibrary
//
//  Created by Liam on 23/12/22.
//

import CoverageDataAccess

typealias CoverageReportFileComparator = ((CoverageReportFile, CoverageReportFile) -> Bool)

public enum CoverageReportFileSortOption: String, CaseIterable {
    case alphabetical
    case highestCoverage    // highest coverage percentage at the top
    case lowestCoverage     // lowest coverage percentage at the top
    case mostLines          // most executable lines at the top
    case biggestGap         // biggest difference between executable lines and covered lines at the top
    case smallestGap        // smallest difference between executable lines and covered lines at the top
    
    /// Get the sorting comparator for this sort option.
    func comparator() -> CoverageReportFileComparator {
        switch self {
        case .alphabetical:
            return { $0.name.lowercased() < $1.name.lowercased() }
        case .highestCoverage:
            return coverageComparator(withPrimary: >)
        case .lowestCoverage:
            return coverageComparator(withPrimary: <)
        case .mostLines:
            return { $0.executableLines > $1.executableLines }
        case .biggestGap:
            return { ($0.executableLines - $0.coveredLines) > ($1.executableLines - $1.coveredLines) }
        case .smallestGap:
            return { ($0.executableLines - $0.coveredLines) < ($1.executableLines - $1.coveredLines) }
        }
    }
    
    /// Create a comparator that primarily checks line coverage and falls back to alphabetical sorting if the coverage values match.
    private func coverageComparator(withPrimary primary: @escaping (Double, Double) -> Bool) -> CoverageReportFileComparator {
        return { lhs, rhs in
            if lhs.formattedLineCoverage() == rhs.formattedLineCoverage() {
                return CoverageReportFileSortOption.alphabetical.comparator()(lhs, rhs)
            }
            return primary(lhs.lineCoverage, rhs.lineCoverage)
        }
    }
}

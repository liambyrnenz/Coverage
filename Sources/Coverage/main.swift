//
//  main.swift
//  Coverage
//
//  Created by Liam on 23/12/22.
//

import CommandLineUtilities
import CoverageCommon
import CoverageDataAccess
import CoverageLibrary

// MARK: Utility functions

private func handleFatalError(message: String, rawLog: String? = nil, hints: [String]? = nil) {
    log.write(message: message, category: .error)
    if let rawLog = rawLog {
        log.write(message: rawLog, category: .output)
    }
    for hint in hints ?? [] {
        log.write(message: hint, category: .hint)
    }
    quit()
}

private func presentReport(target: String?) {
    let presenter = CoverageReportPresenter(resultBundlePath: resultBundlePath)
    do {
        let report: String
        if let target = target {
            log.write(message: "starting coverage report generation for target \(target) in result bundle \(resultBundlePath)" + .newline, category: .info)
            report = try presenter.coverageReport(target: target)
        } else { // assume all targets if no specific target given
            log.write(message: "starting coverage report generation for all targets in result bundle \(resultBundlePath)" + .newline, category: .info)
            report = try presenter.availableTargets()
        }
        
        log.write(message: report)
        log.write(message: "coverage report generated", category: .complete)
        
        if OptionsHelper.shared.writeOption == true {
            let reportFilename = try FileHelper.writeReportToFile(report, resultBundlePath: resultBundlePath)
            log.write(message: "generated report written to file \(reportFilename)", category: .info)
        }
    } catch let error as CoverageRepositoryError {
        handleFatalError(message: error.localizedDescription)
    } catch {
        log.write(error)
    }
}

// MARK: Main script

var arguments = Array(CommandLine.arguments.dropFirst()) // get rid of "./Coverage"

do {
    // Check input arguments for options and remove any that are present
    arguments = try OptionsHelper.shared.evaluate(arguments)
} catch let error as OptionsError {
    switch error {
    case .invalidArguments(let hints):
        handleFatalError(message: error.localizedDescription, hints: hints)
    }
}

// help option
if OptionsHelper.shared.helpOption == true {
    log.write(message: helpText)
    quit()
}

// get result bundle path, depending on options provided
var resultBundlePath: String
if let directoryPath = OptionsHelper.shared.latestInDirectoryOption {
    resultBundlePath = FileHelper.getLatestResultBundle(in: directoryPath)
} else {
    resultBundlePath = arguments[arguments.endIndex - 1] // last argument is practically guaranteed to be a result bundle path
}

if OptionsHelper.shared.viewTargetsOption == true {
    presentReport(target: nil)
} else {
    presentReport(target: arguments[0])
}

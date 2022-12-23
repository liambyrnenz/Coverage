//
//  OptionsHelper.swift
//  CoverageLibrary
//
//  Created by Liam on 23/12/22.
//

import CommandLineUtilities
import CoverageCommon

/// Managing class that helps with evaluating command line options/flags.
///
/// To add a new option to this application, the following steps should be observed:
/// - add the option property to this class and annotate it with the `@Option` property wrapper
/// - add an evaluation method, using the others as a guide
/// - call this method in `evaluate(_:)`
///
/// Note: ensure your option is ordered correctly!
public class OptionsHelper: OptionsHelperProtocol {
    
    public static let shared = OptionsHelper()

    // For the most part, `OptionsHelper` simply reads from the provided arguments, converts
    // the values into stored properties and lets callers inspect the values. Quiet mode and
    // debug options are the exemptions, since these values need to be communicated to the logger
    // immediately.
    
    @Option("-h", "--help")
    public private(set) var helpOption: Bool = false

    @Option("-q", "--quiet")
    public private(set) var quietModeOption: Bool = false {
        didSet {
            log.quietModeEnabled = quietModeOption
        }
    }
    
    @Option("-v", "--view-targets")
    public private(set) var viewTargetsOption: Bool = false
    
    @Option("-l", "--latest")
    public private(set) var latestInDirectoryOption: String?
    
    @Option("-f", "--filter")
    public private(set) var filterOption: [String] = []
    
    @Option("-s", "--sorted")
    public private(set) var sortOption: CoverageReportFileSortOption = .alphabetical
    
    @Option("-x", "--exclude")
    public private(set) var excludeOption: [String] = []
    
    @Option("-r", "--roulette")
    public private(set) var rouletteOption: Bool = false
    
    @Option("-w", "--write")
    public private(set) var writeOption: Bool = false
    
    @Option("-d", "--debug")
    public private(set) var debugOption: Bool = false {
        didSet {
            log.shouldShowDebug = debugOption
        }
    }
    
    /// States whether both the filter and exclude options were provided and whether the filter option
    /// appeared before the exclude option.
    ///
    /// The filter and exclude options can be used together, but the order in which they appear in the
    /// command matters. If the `-f` option precedes the `-x` option, then the list of files will be
    /// filtered and the exclusion process runs on the filtered list, not the original (and vice versa.)
    ///
    /// If this property is `nil`, then the filter and exclude options were not provided together. Otherwise,
    /// this will state whether the filter option appeared first or not.
    public private(set) var filterAppearedBeforeExclude: Bool?
    
}
    
// MARK: - Evaluation methods

extension OptionsHelper {
    
    /// Evaluate the arguments passed to the application for any options that need to be kept track of.
    ///
    /// - Parameter arguments: list of arguments passed to the application, excluding the execution command
    /// - Returns: original list of arguments filtered of any options and their parameters
    /// - Throws: OptionsError if options are malformed
    public func evaluate(_ arguments: [String]) throws -> [String] {
        var arguments = arguments // make mutable for inout evaluation methods
        
        // try and evaluate each type of option set in turn, removing themselves if they are present afterwards
        try evaluateHelpOption(&arguments)
        try evaluateQuietOption(&arguments)
        try evaluateViewTargetsOption(&arguments)
        try evaluateLatestInDirectoryOption(&arguments)
        try evaluateFilterOption(&arguments)
        try evaluateSortOption(&arguments)
        try evaluateExcludeOption(&arguments)
        try evaluateRouletteOption(&arguments)
        try evaluateWriteOption(&arguments)
        try evaluateDebugOption(&arguments)
        
        try evaluateBaseArguments(&arguments)
        
        return arguments
    }
    
}

extension OptionsHelper {
    
    /// Evaluate the given arguments for the presence of the help option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateHelpOption(_ arguments: inout [String]) throws {
        guard let _ = try providedOption(in: arguments, from: $helpOption) else { return }
        
        removeAllOptions(from: &arguments)
        guard arguments.count == 0 else {
            throw OptionsError.invalidArguments(hints: ["other arguments cannot be provided when specifying help mode"])
        }
        
        helpOption = true
        log.write(message: "showing help", category: .option)
    }
    
    /// Evaluate the given arguments for the presence of the quiet mode option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateQuietOption(_ arguments: inout [String]) throws {
        // quiet option needs to be evaluated first to stop log output from this class
        guard let providedOption = try providedOption(in: arguments, from: $quietModeOption) else { return }
        
        quietModeOption = true
        
        remove([providedOption], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of the view targets option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateViewTargetsOption(_ arguments: inout [String]) throws {
        guard let providedOption = try providedOption(in: arguments, from: $viewTargetsOption) else { return }
        
        // the latest in directory option can be used with the view targets option to use directories instead of exact reports
        // use that evaluation method directly
        // if provided, then that method should skip directly after this one
        let latestInDirectoryOption = try self.providedOption(in: arguments, from: $latestInDirectoryOption)
        if latestInDirectoryOption != nil {
            try evaluateLatestInDirectoryOption(&arguments)
        }
        
        viewTargetsOption = true
        log.write(message: "viewing targets for result bundle", category: .option)
        
        remove([providedOption], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of the latest in directory option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateLatestInDirectoryOption(_ arguments: inout [String]) throws {
        guard
            let providedOption = try providedOption(in: arguments, from: $latestInDirectoryOption),
            let optionIndex = arguments.firstIndex(of: providedOption)
            else {
                return
        }
        let directoryArgumentIndex = optionIndex + 1
        
        if arguments.indices.contains(directoryArgumentIndex) == false {
            throw OptionsError.invalidArguments(hints: [
                "please ensure that a directory is specified"
            ])
        }
        
        let directoryArgument = arguments[directoryArgumentIndex]
        self.latestInDirectoryOption = directoryArgument
        log.write(message: "will look for latest result bundle in directory \(directoryArgument) instead of path to result bundle", category: .option)
        
        remove([providedOption, directoryArgument], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of a filter option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateFilterOption(_ arguments: inout [String]) throws {
        guard
            let providedOption = try providedOption(in: arguments, from: $filterOption),
            let optionIndex = arguments.firstIndex(of: providedOption)
            else {
                return
        }
        let filterArgumentsIndex = optionIndex + 1
        
        // check to see if the exclude option is also present, and record the relative positions of the options in the arguments list
        // since this evaluation is performed before the exclusion evaluation, it is only performed here to prevent this occuring twice
        // unnecessarily
        if let excludeOption = try self.providedOption(in: arguments, from: $excludeOption),
           let excludeOptionIndex = arguments.firstIndex(of: excludeOption) {
            let filterAppearedBeforeExclude = optionIndex < excludeOptionIndex
            self.filterAppearedBeforeExclude = filterAppearedBeforeExclude
            log.write(message: "both filter and exclude options are present, filtering \(filterAppearedBeforeExclude ? "will" : "will not") be performed before exclusion", category: .option)
        }
        
        if arguments.indices.contains(filterArgumentsIndex) == false {
            throw OptionsError.invalidArguments(hints: [
                "please ensure that filters are specified",
                "you can specify multiple filters with commas (e.g. \"View,Presenter\")"
            ])
        }
        
        let filterArguments = arguments[filterArgumentsIndex].split(separator: ",").map(String.init)
        self.filterOption = filterArguments
        log.write(message: "filtering report to show only files/targets containing \(filterArguments)", category: .option)
        
        remove([providedOption, arguments[filterArgumentsIndex]], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of a sort option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateSortOption(_ arguments: inout [String]) throws {
        guard
            let providedOption = try providedOption(in: arguments, from: $sortOption),
            let optionIndex = arguments.firstIndex(of: providedOption)
            else {
                return
        }
        let sortOptionIndex = optionIndex + 1
        
        if arguments.indices.contains(sortOptionIndex) == false {
            throw OptionsError.invalidArguments(hints: [
                "please ensure that a sort option is specified",
                "available sort options are \(CoverageReportFileSortOption.allCases.map(\.rawValue))",
                "you can also use indexes (e.g. `.alphabetical` would be 0)"
            ])
        }
        
        if let sortOption = CoverageReportFileSortOption(rawValue: arguments[sortOptionIndex]) {
            self.sortOption = sortOption
        } else if let sortOptionNumber = Int(arguments[sortOptionIndex]), sortOptionNumber < CoverageReportFileSortOption.allCases.count {
            self.sortOption = CoverageReportFileSortOption.allCases[sortOptionNumber]
        } else {
            throw OptionsError.invalidArguments(hints: [
                "an invalid sort option was provided, available sort options are \(CoverageReportFileSortOption.allCases.map(\.rawValue))",
                "if using indexes, make sure the index is in range"
            ])
        }
        
        log.write(message: "sort option provided, coverage report files/targets will be sorted by option \(sortOption)", category: .option)
        if sortOption == .smallestGap {
            log.write(message: "smallest gap sort option selected, files/targets at 100% coverage will be omitted from report", category: .info)
        }
        
        remove([providedOption, arguments[sortOptionIndex]], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of an exclude option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateExcludeOption(_ arguments: inout [String]) throws {
        guard
            let providedOption = try providedOption(in: arguments, from: $excludeOption),
            let optionIndex = arguments.firstIndex(of: providedOption)
            else {
                return
        }
        let excludeArgumentsIndex = optionIndex + 1
        
        if arguments.indices.contains(excludeArgumentsIndex) == false {
            throw OptionsError.invalidArguments(hints: [
                "please ensure that exclusion terms are specified",
                "you can specify multiple exclusions with commas (e.g. \"View,Presenter\")"
            ])
        }
        
        let excludeArguments = arguments[excludeArgumentsIndex].split(separator: ",").map(String.init)
        self.excludeOption = excludeArguments
        log.write(message: "excluding files/targets containing \(excludeArguments) from report", category: .option)
        
        remove([providedOption, arguments[excludeArgumentsIndex]], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of the roulette option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateRouletteOption(_ arguments: inout [String]) throws {
        guard let providedOption = try providedOption(in: arguments, from: $rouletteOption) else { return }
        
        rouletteOption = true
        log.write(message: "roulette mode enabled, selecting a single random file/target for report", category: .option)
        
        remove([providedOption], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of the write option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateWriteOption(_ arguments: inout [String]) throws {
        guard let providedOption = try providedOption(in: arguments, from: $writeOption) else { return }
        
        writeOption = true
        log.write(message: "write mode enabled, will write report into file after generation", category: .option)
        
        remove([providedOption], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of the debug option.
    ///
    /// - Parameters:
    ///   - arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if options are missing or malformed
    private func evaluateDebugOption(_ arguments: inout [String]) throws {
        guard let providedOption = try providedOption(in: arguments, from: $debugOption) else { return }
        
        debugOption = true
        log.write(message: "debug mode enabled", category: .option)
        
        remove([providedOption], fromArguments: &arguments)
    }
    
    /// Evaluate the given arguments for the presence of the required base arguments.
    ///
    /// - Parameter arguments: arguments list from `evaluate(_:)`
    /// - Throws: OptionsError if arguments are missing or malformed
    private func evaluateBaseArguments(_ arguments: inout [String]) throws {
        // don't execute this if help option was selected
        if helpOption { return }
        
        removeAllOptions(from: &arguments)
        
        // if the view targets option is provided by itself, only accept one argument (result bundle)
        if viewTargetsOption == true, latestInDirectoryOption == nil {
            guard arguments.count == 1 else {
                throw OptionsError.invalidArguments(hints: [
                    "only the result bundle can be provided as a base argument if using \($viewTargetsOption.longest!) (without \($latestInDirectoryOption.longest!))"
                ])
            }
        }
        
        // if the view targets option is provided using latest in directory, don't take any arguments (no target and directory is handled by the latest option)
        if viewTargetsOption == true, latestInDirectoryOption != nil {
            guard arguments.count == 0 else {
                throw OptionsError.invalidArguments(hints: [
                    "no base arguments can be provided when using \($viewTargetsOption.longest!) and \($latestInDirectoryOption.longest!) together"
                ])
            }
        }
        
        if viewTargetsOption == false, latestInDirectoryOption != nil {
            guard arguments.count == 1 else { // ensure the only provided argument was the target
                throw OptionsError.invalidArguments(hints: [
                    "only the target name can be provided as a base argument if -l/--latest is enabled"
                ])
            }
        }
        
        if latestInDirectoryOption == nil, viewTargetsOption == false {
            guard arguments.count == 2 else {
                throw OptionsError.invalidArguments(hints: [
                    "Coverage requires two arguments (target and result bundle), please try again"
                ])
            }
            guard arguments[1].hasSuffix(".xcresult") else {
                throw OptionsError.invalidArguments(hints: [
                    "are you using a valid result bundle with extension .xcresult?"
                ])
            }
        }
    }
    
}

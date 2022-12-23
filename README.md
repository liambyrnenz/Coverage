# Coverage
## Xcode Code Coverage 2: Back With A Vengeance

Sick of the Xcode code coverage report not showing what you *really* want to know? Tired of endlessly scrolling through methods and files you don't care about? Now introducing **Coverage**, the extensible Xcode code coverage CLI tool!

#### What? Tell me more!

Coverage is a command-line application* that utilises Xcode's CLI tools for generating code coverage information (presumably the same tools it uses to create the GUI report) to create a textual report that can be manipulated more than Xcode's inbuilt graphical report.

As well as providing the standard features of showing files in a specified target with their respective code coverage metrics and sorting by highest and lowest coverage, Coverage provides the ability to format the report to show only what is relevant to the user. For example, when looking at a code coverage report for an iOS app, the developer will likely want to only see coverage metrics for components that can be adequately covered by unit tests, such as presenters, utilities and data access classes. The developer can use Coverage's filtering option to trim the list of files down to any file that contains a given string (e.g. "presenter".) This makes scanning a report much easier as the developer does not need to sift through files that can't be easily covered or files that aren't relevant to the context (e.g. if the developer only wants to see files created for a recent feature.)

* This tool was originally a Mac application but is now a Swift Package, so it can take advantage of local command-line tool packages and be used in more contexts, such as project build phases. 

#### That sounds awesome! How do I use it?

To use Coverage, grab the executable file from this repository and make it executable if needed (`chmod +x Coverage`). Then, use the steps below to create a report.

If you choose to clone the repository and want to generate new builds other that the one provided, use the `deploy.sh` script to run builds and copy them into the `executables` directory.

## Commands

The basic usage of Coverage is:

> `./Coverage <target name> <path to result bundle>`

where a result bundle is the set of files that Xcode generates when a unit test build is performed. This can be found by going to the Reports tab in the Xcode navigator (Cmd+9), right-clicking on a coverage report and clicking "Show in Finder". The bundle can then be dragged into the terminal to copy in its absolute filepath.

Targets have to specified exactly for the tool to run. To see the list of available targets, run the following:

> `./Coverage -v <path to result bundle>`

You can then copy the desired target into the report generating command.

You can also specify the directory where the result bundles for your project are located using the `-l/--latest` option to automatically produce a report against the most recently created result bundle in the directory. See the Options section below for more information.

### Path to result bundle

Generally, you should be able to find result bundles for your projects in the following directory:
`/Users/<username>/Library/Developer/Xcode/DerivedData/<project>/Logs/Test/`

## How to read the report

A standard coverage report for a target looks like this:

```
ComputedDefault.swift                   [========            ]     41.7% (5/12 lines)
CoreLocation.swift                      [====================]     100.0% (19/19 lines)
Logging.swift                           [====================]     100.0% (7/7 lines)
NumberFormatterHelper.swift             [=================== ]     98.5% (64/65 lines)
OSLogDestination.swift                  [=================   ]     89.2% (58/65 lines)
RawRepresentable.swift                  [                    ]     0.0% (0/15 lines)
```

The left-most column shows the file name. The right columns show the relative coverage (each bar is 5%) and the metrics (total coverage percentage and executable lines covered.)

## Options

The following options can be provided to Coverage. You may provide options in any order. For example, you could place the options before the base arguments of the target and result bundle path, or they could be placed after the base arguments.

These options are used to format the report differently. They can be freely combined, unless specified otherwise:
- `-f <filter string>` or `--filter <filter string>`
  - Filters the list of files down to those that contain the given strings (you can provide multiple values separated by commas, e.g. `View,Cell`). Comparisons are case-sensitive. This can be used in conjuction with `-x`/`--exclude` - the order of the options decide the order of these actions.
- `-x <exclude string>` or `--exclude <exclude string>`
  - Excludes files containing the given strings (you can provide multiple values separated by commas, e.g. `View,Cell`) from the list of files. Comparisons are case-sensitive. This can be used in conjuction with `-f`/`--filter` - the order of the options decide the order of these actions.
- `-s <sort option>` or `--sorted <sort option>`
  - Sorts the list of files by a predefined sort option. Note that the options must be specified exactly as written. See below for available sort options.
- `-q` or `--quiet`
  - Silences non-essential output for easier reading of the report.
- `-r` or `--roulette`
  - Produces a report with a single, random file that is yet to be fully covered. Good for quickly picking a file to add tests to.
- `-w` or `--write`
  - Writes the report to a file in the current directory. The file name is based on the name of the result bundle that was used to generate the report.
- `-d` or `--debug`
  - Enables more verbose logging for debugging purposes.

These options change how reports are generated. They can be used with the formatting options above:
- `-v` or `--view-targets`
  - View the list of targets in this result bundle and their overall coverage metrics. This option must be specified with only the result bundle OR it can be used with `-l`/`--latest`.
- `-l <directory path>` or `--latest <directory path>`
  - Allows the directory where result bundles for your project are stored to be specified instead of paths to individual result bundles. When this option is used, the most recently created result bundle in the directory is automatically provided to the tool to create a report against, meaning you can run your tests and go back to your terminal and re-run the same command without having to drag in the new result bundle. Note that when this option is used, you cannot specify a result bundle in the normal fashion.

These options are standalone and cannot be combined with the above options, unless specified otherwise:
- `-h` or `--help`
  - Shows the Options section from this document for a quick help reference.

### Sort options

```
alphabetical
highestCoverage    // highest coverage percentage at the top
lowestCoverage     // lowest coverage percentage at the top
mostLines          // most executable lines at the top
biggestGap         // biggest difference between executable lines and covered lines at the top
smallestGap        // smallest difference between executable lines and covered lines at the top
```

## Testing

To run the tests for this package, either use Xcode's testing suite or use the command `swift test` in the terminal. And yes, you can use this tool to view the code coverage reports for its own tests!

## Help

### I can't run the executable on macOS Catalina (or above) because the developer is unverified

Run the app by locating it in Finder and double-clicking it. This will prompt you to open the app despite it being unverified and save the choice made, enabling use in the terminal. If this doesn't work, try looking in your System Preferences to see if you can allow access from there.


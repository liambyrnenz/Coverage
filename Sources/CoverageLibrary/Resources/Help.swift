//
//  Help.swift
//  CoverageLibrary
//
//  Created by Liam on 23/12/22.
//

// note that this is simply the "Options" section from the README
public let helpText = """
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
"""

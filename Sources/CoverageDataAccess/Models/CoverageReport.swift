//
//  CoverageReport.swift
//  CoverageDataAccess
//
//  Created by Liam on 23/12/22.
//

public struct CoverageReport: Codable {
    public let product: String
    public let files: [CoverageReportFile]
    
    internal init(product: String, files: [CoverageReportFile]) {
        self.product = product
        self.files = files
    }
}

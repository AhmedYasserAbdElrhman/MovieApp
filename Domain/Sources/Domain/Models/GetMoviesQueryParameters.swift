//
//  GetMoviesQueryParameters.swift
//  Data
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import Foundation
public struct GetMoviesQueryParameters: Encodable {
    var page: Int
    var language: String
    var query: String?
    public init(
        page: Int,
        query: String? = nil,
        language: String = "en-US"
    ) {
        self.page = page
        self.query = query
        self.language = language
    }
}

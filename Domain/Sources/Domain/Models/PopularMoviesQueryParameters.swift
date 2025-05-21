//
//  PopularMoviesQueryParameters.swift
//  Data
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import Foundation
public struct PopularMoviesQueryParameters: Encodable {
    var page: Int
    var language: String
    public init(page: Int, language: String = "en-US") {
        self.page = page
        self.language = language
    }
}

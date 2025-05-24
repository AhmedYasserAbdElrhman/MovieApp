//
//  File.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//

import Foundation
public struct MovieCredits: Decodable, Sendable {
    let id: Int
    public let cast: [Person]
    public let crew: [Person]
}

public struct Person: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let knownForDepartment: String
    public let popularity: Double
    public let profilePath: String?
    public let job: String?
}

//
//  File.swift
//  Domain
//
//  Created by Ahmad Yasser on 23/05/2025.
//

import Foundation
public struct MovieCredits: Decodable {
    let id: Int
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Decodable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let popularity: Double
}

struct Crew: Decodable {
    let id: Int
    let name: String
    let department: String
    let job: String
    let profilePath: String?
    let popularity: Double
}

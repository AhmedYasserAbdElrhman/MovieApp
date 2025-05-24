//
//  PersonPresentationModel.swift
//  Features
//
//  Created by Ahmad Yasser on 24/05/2025.
//

import Data
import Domain
struct PersonPresentationModel: TMDBProfileProviding {
    let id: Int
    let name: String
    let profilePath: String?
    let popularity: Double
    
    init(from entity: Person) {
        self.id = entity.id
        self.name = entity.name
        self.profilePath = entity.profilePath
        self.popularity = entity.popularity
    }
}

extension Person {
    var isDirector: Bool { knownForDepartment == "Directing" && job == "Director" }
}

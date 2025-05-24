//
//  SimilarMoviePresentationModel.swift
//  Features
//
//  Created by Ahmad Yasser on 24/05/2025.
//

import Data
import Domain
struct SimilarMoviePresentationModel: TMDBPosterProviding {
    let id: Int
    let title: String
    let posterPath: String?
    init(from entity: Domain.Movie) {
        self.id = entity.id
        self.title = entity.title
        self.posterPath = entity.posterPath
    }
}

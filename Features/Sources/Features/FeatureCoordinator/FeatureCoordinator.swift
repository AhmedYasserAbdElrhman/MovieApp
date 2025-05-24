//
//  FeatureCoordinator.swift
//  Features
//
//  Created by Ahmad Yasser on 24/05/2025.
//

import UIKit
public class FeatureCoordinator {
    weak var navigationController: UINavigationController?
    public init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    @MainActor
    public func start() {
        let viewController = MovieListConfigurator.configure(navigation: handleMovieNavigation(_:))
        navigationController?.setViewControllers( [viewController], animated: false)
    }
    @MainActor
    func handleMovieNavigation(_ navigation: MovieListNavigation) {
        switch navigation {
        case let .movieDetails(id, callback):
            let detailViewController = MovieDetailsConfigurator.configure(
                movieId: id,
                callback: callback
            )
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}

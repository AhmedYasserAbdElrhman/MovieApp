//
//  UIImageView+Kingfisher.swift
//  Utils
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import UIKit

#if canImport(Kingfisher)
import Kingfisher
#endif

public extension UIImageView {
    /// Sets an image from a URL using Kingfisher, if available.
    /// - Parameters:
    ///   - url: The URL of the image.
    ///   - placeholder: A placeholder image to display while loading.
    func setImage(with url: URL?, placeholder: UIImage? = nil) {
        #if canImport(Kingfisher)
        let downsamplingProcesspr = DownsamplingImageProcessor(
            size: self.bounds.size
        )
        let roundedCornerProcessor = RoundCornerImageProcessor(
            cornerRadius: self.layer.cornerRadius
        )
        let processor =  downsamplingProcesspr |> roundedCornerProcessor
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .backgroundDecode,
                .processor(processor)
            ]
        )
        #else
        // Fallback: set placeholder or nil if Kingfisher is not available.
        self.image = placeholder
        #endif
    }
}

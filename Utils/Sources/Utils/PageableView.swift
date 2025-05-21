//
//  PageableView.swift
//  Utils
//
//  Created by Ahmad Yasser on 21/05/2025.
//

import UIKit
import Combine
public protocol PageableView where Self: UIViewController {
    var scroll: UIScrollView {get}
    var isBottom: Bool {get}
    var reachedBottomSubject: PassthroughSubject<Void, Never> { get }
}

public extension PageableView {
    var isBottom: Bool {
        return (scroll.contentOffset.y + scroll.frame.height) >= scroll.contentSize.height
    }
    func didEndScrolling() {
        guard isBottom else { return }
        reachedBottomSubject.send()
    }
}

//
//  ViewModelType.swift
//  Features
//
//  Created by Ahmad Yasser on 21/05/2025.
//


import Foundation
@MainActor
protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

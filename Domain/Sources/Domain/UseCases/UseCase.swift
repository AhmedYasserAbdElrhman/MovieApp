//
//  UseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 21/05/2025.
//


protocol UseCase {
    associatedtype RequestValue
    associatedtype ResponseValue
    
    func execute(requestValue: RequestValue) async throws -> ResponseValue
}

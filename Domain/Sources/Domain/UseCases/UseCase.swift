//
//  UseCase.swift
//  Domain
//
//  Created by Ahmad Yasser on 21/05/2025.
//


public protocol UseCase {
    associatedtype RequestValue
    associatedtype ResponseValue
    
    func execute(requestValue: RequestValue) async throws -> ResponseValue
}

extension UseCase where RequestValue == () {
    /// sugar-overload so you can just call `execute()` when there are no args
    public func execute() async throws -> ResponseValue {
        try await execute(requestValue: ())
    }
}

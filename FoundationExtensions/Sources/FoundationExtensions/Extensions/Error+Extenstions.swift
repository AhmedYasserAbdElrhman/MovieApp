//
//  Error+Extenstions.swift
//  FoundationExtensions
//
//  Created by Ahmad Yasser on 23/05/2025.
//

import CoreData
extension Error {
    /// Returns a user-friendly message for common Core Data errors.
    public var coreDataFriendlyMessage: String {
        let nsError = self as NSError
        guard nsError.domain == NSCocoaErrorDomain else {
            return nsError.localizedDescription
        }
        
        switch nsError.code {
            // MARK: – Validation errors
        case NSManagedObjectValidationError:
            return "An object failed to validate."
        case NSValidationMultipleErrorsError:
            return "Multiple validation errors occurred."
        case NSValidationMissingMandatoryPropertyError:
            return "A required field is missing."
        case NSValidationNumberTooLargeError:
            return "The number you entered is too large."
        case NSValidationNumberTooSmallError:
            return "The number you entered is too small."
        case NSValidationStringTooLongError:
            return "The text you entered is too long."
        case NSValidationStringTooShortError:
            return "The text you entered is too short."
        case NSValidationStringPatternMatchingError:
            return "The text you entered has an invalid format."
            
            // MARK: – Unique constraint violations
        case NSManagedObjectConstraintValidationError:
            // code 1551: you’ve broken a uniqueness rule on a *new* object
            return "A data uniqueness rule was violated."
        case NSManagedObjectConstraintMergeError:
            // code 133021: merge policy couldn't reconcile conflicting constraints
            return "This item already exists in your watchlist."
            
            // MARK: – Other persistent‐store errors you might see
        case NSPersistentStoreSaveError:
            return "The persistent store failed to save."
        case NSPersistentStoreIncompleteSaveError:
            return "Some data couldn’t be saved."
        case NSPersistentStoreOperationError:
            return "A persistent-store operation failed."
        default:
            print(nsError.code)
            return nsError.localizedDescription
        }
    }
}

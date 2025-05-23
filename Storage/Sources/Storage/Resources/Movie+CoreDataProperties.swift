//
//  Movie+CoreDataProperties.swift
//  Storage
//
//  Created by Ahmad Yasser on 23/05/2025.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var id: Int64

}

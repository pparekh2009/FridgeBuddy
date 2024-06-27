//
//  Product+CoreDataProperties.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/19/24.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var lastDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var quantity: String?

}

extension Product : Identifiable {

}

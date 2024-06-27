//
//  ShoppingItem+CoreDataProperties.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/19/24.
//
//

import Foundation
import CoreData


extension ShoppingItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingItem> {
        return NSFetchRequest<ShoppingItem>(entityName: "ShoppingItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var bought: Bool

}

extension ShoppingItem : Identifiable {

}

//
//  Character+CoreDataProperties.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/25/21.
//
//

import Foundation
import CoreData


extension Character {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var dndClass: String?
    @NSManaged public var iconName: String?
    @NSManaged public var level: String?
    @NSManaged public var name: String?
    @NSManaged public var spells: NSSet?

}

// MARK: Generated accessors for spells
extension Character {

    @objc(addSpellsObject:)
    @NSManaged public func addToSpells(_ value: Spell)

    @objc(removeSpellsObject:)
    @NSManaged public func removeFromSpells(_ value: Spell)

    @objc(addSpells:)
    @NSManaged public func addToSpells(_ values: NSSet)

    @objc(removeSpells:)
    @NSManaged public func removeFromSpells(_ values: NSSet)

}

extension Character : Identifiable {

}

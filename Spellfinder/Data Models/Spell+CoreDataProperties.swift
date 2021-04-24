//
//  Spell+CoreDataProperties.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//
//

import Foundation
import CoreData


extension Spell {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Spell> {
        return NSFetchRequest<Spell>(entityName: "Spell")
    }

    @NSManaged public var archetype: String?
    @NSManaged public var castingTime: String?
    @NSManaged public var circles: String?
    @NSManaged public var components: String?
    @NSManaged public var concentration: String?
    @NSManaged public var desc: String?
    @NSManaged public var dndClass: String?
    @NSManaged public var duration: String?
    @NSManaged public var higherLevelDesc: String?
    @NSManaged public var isConcentration: Bool
    @NSManaged public var isFavorited: Bool
    @NSManaged public var isRitual: Bool
    @NSManaged public var level: String?
    @NSManaged public var levelNum: Double
    @NSManaged public var material: String?
    @NSManaged public var name: String?
    @NSManaged public var page: String?
    @NSManaged public var range: String?
    @NSManaged public var ritual: String?
    @NSManaged public var school: String?
    @NSManaged public var slug: String?
    @NSManaged public var character: NSSet?

}

// MARK: Generated accessors for character
extension Spell {

    @objc(addCharacterObject:)
    @NSManaged public func addToCharacter(_ value: Character)

    @objc(removeCharacterObject:)
    @NSManaged public func removeFromCharacter(_ value: Character)

    @objc(addCharacter:)
    @NSManaged public func addToCharacter(_ values: NSSet)

    @objc(removeCharacter:)
    @NSManaged public func removeFromCharacter(_ values: NSSet)

}

extension Spell : Identifiable {

}

//
//  SearchResult.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/7/21.
//

import Foundation

// TO-DO: Integrate this with Core Data AND the API
class ResultArray: Codable {
    var count = 0
    var next: String?
    var previous: String?
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible, FavoritingSpellsProtocol {
    // Information from API
    var name: String? = ""
    var slug: String? = ""
    var desc: String? = ""
    var higherLevelDesc: String? = ""
    var page: String? = ""
    var range: String? = ""
    var components: String? = ""
    var material: String? = ""
    var ritual: String? = ""
    var duration: String? = ""
    var concentration: String? = ""
    var castingTime: String? = ""
    var level: String? = ""
    var levelNum: Double?
    var school: String? = ""
    var dndClass: String? = ""
    var archetype: String? = ""
    var circles: String? = ""
  
    // Other properties
    var isConcentration: Bool {
      if concentration == "yes" {
        return true
      } else if concentration == "no" {
        return false
      }
      return false
    }
    var isRitual: Bool {
      if ritual == "yes" {
        return true
      } else if ritual == "no" {
        return false
      }
      return false
    }
  
    // Conform to the FavoritingSpellsProtocol
    var isFavorited: Bool = false
    
    // Define encoding mapping from API information onto variables in this class
    enum CodingKeys: String, CodingKey {
      case name, slug, desc
      case higherLevelDesc = "higher_level"
      case page, range, components, material, ritual
      case duration, concentration
      case castingTime = "casting_time"
      case level
      case levelNum = "level_int"
      case school, archetype, circles
      case dndClass = "dnd_class"
    }
    
    // Format information for debugging
    var description: String {
        return "\nResult - Name: \(name ?? "None"), School of Magic: \(school as String?)" +
               "Description: \(desc ?? "None"), Duration: \(duration ?? "None")" +
               " Level: \(level ?? "None"), isFavorited: \(isFavorited)"
    }
}

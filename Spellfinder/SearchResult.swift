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

class SearchResult: Codable, CustomStringConvertible {
    var name: String? = ""
    var school: String? = ""
    
    var description: String {
        return "\nResult - Name: \(name ?? "None"), School of Magic: \(school as String?)"
    }
}

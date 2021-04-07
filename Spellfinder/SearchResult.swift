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
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    var name: String? = ""
    var url: String? = ""
    
    var description: String {
        return "\nResult - Name: \(name ?? "None"), URL: \(url as String?)"
    }
}

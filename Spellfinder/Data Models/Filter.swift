//
//  Filter.swift
//  Spellfinder
//
//  Created by Eva Yan on 5/3/21.
//

import Foundation

class Filter {
    
    // MARK: - Instance Variables
    var levelFilter: Set<Double> = []
    var classFilter: Set<String> = []
    var componentsFilter: Set<String> = []
    var schoolFilter: Set<String> = []
    var concentrationFilter: Set<String> = []
    
    // Storage
    var levelIndex: Int = 0
    var classIndexes: Set<Int> = []
    var componentsIndexes: Set<Int> = []
    var schoolIndex: Int = 0
    var concentrationIndex: Int = 0
    
    var levelString: String = ""
    var classString: String = ""
    var componentsString: String = ""
    var schoolString: String = ""
    var concentrationString: String = ""
    
    // Format information for debugging
    var description: String {
        return "Filter: \nLevel: \(levelFilter)\n Class: \(classFilter)\n" +
               "Components: \(componentsFilter)\n School: \(schoolFilter)\n Concentration: \(concentrationFilter)"
    }
}

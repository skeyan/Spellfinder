//
//  Search.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

import Foundation
import UIKit

// Contains the search logic within a class
// Provides centralized access to the search state and results
typealias SearchComplete = (Bool) -> Void
class Search {
    
    // MARK: - Search Variables
    var searchResults: [SearchResult] = []
    var searchResultsDict = Dictionary<String, SearchResult>()
    var searchResultsKeysByName = [String]()
    var searchResultsKeysByLevel = [String]()
    var slugs: [String]?
    
    // Keep the state - have we finished searching?
    var hasSearched = false
    
    // Keep the state - are we downloading stuff from API?
    var isLoading = false
    
    // Keep track of our data task so it may be cancelled
    private var dataTask: URLSessionDataTask?
    
    // Filters for search results
    var filters: Filter?

    // MARK: - Search Methods
    func performSearch(
        for text: String,
        firstLoad: Bool,
        coreDataSpells: [Spell]?,
        completion: @escaping SearchComplete
    ) {
        // Indicate we are getting data from API
        dataTask?.cancel()
        isLoading = true
        hasSearched = true
       
        let url = spellsURL(searchText: text)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) {data, response, error in
            var success = false
            if let error = error as NSError?, error.code == -999 {
                DispatchQueue.main.async {
                    self.showAlert()
                }
                print("Failure! \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 {
                print("Success!")
                if let data = data {
                    // Parse JSON on a background thread
                    self.searchResults = self.parse(data: data)
                    self.searchResults = self.filterSearchResults()
                    self.slugs = self.spellsArrayToSlugs(self.searchResults)
                    self.spellsArrayToDict(self.searchResults)
                    self.coreDataOverwrite(coreDataSpells!)

                    DispatchQueue.main.async {
                        self.isLoading = false
                        success = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert()
                }
                print("Failure! \(response!)")
            }
            
            // Inform user of network error
            DispatchQueue.main.async {
                if !success {
                    self.hasSearched = false
                    self.isLoading = false
                }
                completion(success)
            }
        }
        
        // Start the data task on an async background thread
        dataTask?.resume()
    }
    
    // Creates the properly encoded API URL to gather spells
    private func spellsURL(
        searchText: String 
    ) -> URL {
        let encodedText = searchText.addingPercentEncoding(
              withAllowedCharacters: CharacterSet.urlQueryAllowed)!
          let urlString = String(format: "https://api.open5e.com/spells/?limit=400&search=%@", encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    // Parse the JSON data into SearchResults
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            DispatchQueue.main.async {
                self.showAlert()
            }
            print("JSON Decoding Error: \(error)")
            return []
        }
    }
    
    // Show alert on error
    func showAlert() -> Void {
        let alertController = UIAlertController(title: "Error with data", message: "The data could not be retrieved and parsed successfully from the API.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertController.show()
    }
    
    // MARK: - Methods for Filtered Spells
    // Convert array of spells to array of slugs as strings only
    private func spellsArrayToSlugs(_ arr: [SearchResult]) -> [String] {
        var slugs = [String]()
        for spell in arr {
            slugs.append(spell.slug!)
        }
        return slugs
    }
    
    private func filterSearchResults() -> [SearchResult] {
        var filteredSearchResults: [SearchResult] = []
        
        filteredSearchResults = searchResults.filter { searchResult in
            return filterHelper(searchResult)
        }
        
        return filteredSearchResults
    }
    
    private func filterHelper(_ searchResult: SearchResult) -> Bool {
        var passesFilter = true
        if let filters = filters {
            // Level must be one of those selected
            if !((filters.levelFilter.contains(searchResult.levelNum!))) {
                passesFilter = false
            }
            
            // Classes must include all selected, at least
            if !(filters.classFilter.isSubset(of: Set(searchResult.dndClass!.components(separatedBy: ", ")))) {
                passesFilter = false
            }
            
            // Components must include all selected, at least
            if !(filters.componentsFilter.isSubset(of: Set(searchResult.components!.components(separatedBy: ", ")))) {
                passesFilter = false
            }
            
            // School must include that which was selected
            if !(filters.schoolFilter.contains(searchResult.school!)) {
                passesFilter = false
            }
            
            // Concentration must include that which was selected
            if !(filters.concentrationFilter.contains(searchResult.concentration!)) {
                passesFilter = false
            }
        }
        
        return passesFilter
    }
 
    // MARK: - Methods for All Spells
    // Convert array of spells to dictionary of spells and populate instance variables
    private func spellsArrayToDict(_ arr: [SearchResult]) -> Void {
        var newSearchResultsDict = Dictionary<String, SearchResult>()
        var newSearchResultsKeysByName = [String]()
        var newSearchResultsKeysByLevel = [String]()
        
        // By Name
        for spell in arr {
            newSearchResultsDict[spell.slug!] = spell
            newSearchResultsKeysByName.append(spell.slug!)
        }
        newSearchResultsKeysByName.sort { $0 < $1 }
        searchResultsKeysByName = newSearchResultsKeysByName
        searchResultsDict = newSearchResultsDict
        
        // By Level
        var searchResultsSortedByLevel: [SearchResult] = searchResults
        searchResultsSortedByLevel.sort{ $0.levelNum! < $1.levelNum! }
        for spell in searchResultsSortedByLevel {
            newSearchResultsKeysByLevel.append(spell.slug!)
        }
        searchResultsKeysByLevel = newSearchResultsKeysByLevel
    }
    
    // Use Core Data favorited spells to overwrite instance array from API
    private func coreDataOverwrite(_ spellEntities: [Spell]) -> Void {
        for spell in spellEntities {
            searchResultsDict[spell.slug!]?.isFavorited = spell.isFavorited
        }
    }
}




//
//  Search.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

import Foundation

// Contains the search logic within a class
// Provides centralized access to the search state and results
typealias SearchComplete = (Bool) -> Void
class Search {
    // MARK: - Search Variables
    var searchResults: [SearchResult] = []
    var searchResultsDict = Dictionary<String, SearchResult>()
    var searchResultsKeysByName = [String]()
    var searchResultsKeysByLevel = [String]()
    
    // Keep the state - have we finished searching?
    var hasSearched = false
    
    // Keep the state - are we downloading stuff from API?
    var isLoading = false
    
    // Keep track of our data task so it may be cancelled
    private var dataTask: URLSessionDataTask?

    // MARK: - Search Methods
    func performSearch(
        for text: String,
        firstLoad: Bool,
        completion: @escaping SearchComplete
    ) {
        print("The search text is '\(text)'")
        
        // Perform search
        if firstLoad || !text.isEmpty {
            
            // Indicate we are getting data from API
            dataTask?.cancel()
            isLoading = true
            
            // Get all spells from the API
            hasSearched = true
           
            let url = spellsURL(searchText: text)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) {data, response, error in
                var success = false
                if let error = error as NSError?, error.code == -999 {
                    print("Failure! \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 {
                    print("Success!")
                    if let data = data {
                        // Parse JSON on a background thread
                        self.searchResults = self.parse(data: data)
                        self.spellsArrayToDict(self.searchResults)
                        // TO-DO: Core Data Overwrite Favorites

                        DispatchQueue.main.async {
                            self.isLoading = false
                            success = true
                        }
                    }
                }
                else {
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
    }
    
    // Parse the JSON data
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Decoding Error: \(error)")
            return []
        }
    }
    
    // Creates the properly encoded API URL to gather spells
    private func spellsURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(
              withAllowedCharacters: CharacterSet.urlQueryAllowed)!
          let urlString = String(
            format: "https://api.open5e.com/spells/?limit=400&search=%@",
            encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
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
}




//
//  TempCode.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

/*
func performSearch(firstLoad: Bool) {
    print("The search text is '\(searchBar.text!)'")
    
    // Perform search
    if firstLoad || !searchBar.text!.isEmpty {
        // Remove keyboard after search is performed
        searchBar.resignFirstResponder()
        
        // Indicate we are getting data from API
        dataTask?.cancel()
        isLoading = true
        tableView.reloadData()
        
        // Get all spells from the API
        hasSearched = true
       
        let url = spellsURL(searchText: searchBar.text!)
        let session = URLSession.shared
        dataTask = session.dataTask(with: url) {data, response, error in
            if let error = error as NSError?, error.code == -999 {
                print("Failure! \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 {
                if let data = data {
                    // Parse JSON on a background thread
                    self.searchResults = self.parse(data: data)
                    self.spellsArrayToDict(self.searchResults)

                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.handleLoadSegment()
                        self.tableView.reloadData()
                    }
                    return
                }
            }
            else {
                print("Failure! \(response!)")
            }
            
            // Inform user of network error
            DispatchQueue.main.async {
                self.hasSearched = false
                self.isLoading = false
                self.tableView.reloadData()
                self.showNetworkError()
            }
        }
        
        // Start the data task on an async background thread
        dataTask?.resume()
    }
}
*/

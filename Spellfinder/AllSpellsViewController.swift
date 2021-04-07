//
//  ViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/1/21.
//

import UIKit

class AllSpellsViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Instance Variables
    // Store our search results
    var searchResults = [SearchResult]()
    
    // Keep the state - have we finished searching?
    var hasSearched = false
    
    // Keep the state - are we downloading stuff from API?
    var isLoading = false
    
    struct TableView {
      struct CellIdentifiers {
        static let loadingCell = "LoadingCell"
      }
    }
    
    // TO-DO: Implement advanced search with filtering
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        // Debug
        print("Segment changed: \(sender.selectedSegmentIndex)")
        
        // TO-DO: Change sorting method for table view
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent search bar from omverlapping the table view
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // 94
 
        // Change color of segmented control text
        let themeColor = UIColor(red: 27/255, green: 181/255, blue: 242/255, alpha: 1)
        UISegmentedControl.appearance().setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: themeColor], for: .selected)
        
        // Register loading cell nib
        let cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        // TO-DO: Integrate this with Core Data? Make more API calls for details?
        performSearch()
    }
    
    // Retrieve spells from the API; currently all spells
    func performSpellsRequest(with url: URL) -> Data? {
        do {
            print("Download Success")
            return try Data(contentsOf: url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
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
    
    // Display network error to user
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an error accessing the spells API. " +
            "Please try again.",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Search Bar Delegate
extension AllSpellsViewController: UISearchBarDelegate {
    // TO-DO: Make search call API and display results on app load
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        // Debug
        print("The search text is '\(searchBar.text!)'")
        
        // Perform search
        if searchBar.text!.isEmpty { // TO-DO: detect when run once?
            // Remove keyboard after search is performed
            searchBar.resignFirstResponder()
            
            // Indicate we are getting data from API
            isLoading = true
            tableView.reloadData()
            
            // Get all spells from the API
            searchResults = []
            hasSearched = true
            
            let queue = DispatchQueue.global()
            let url = self.spellsURL(searchText: searchBar.text!)
            print("URL: '\(url)'")
            
            queue.async {
                if let data = self.performSpellsRequest(with: url) {
                    // Update with results from search
                    self.searchResults = self.parse(data: data)
                    print("Got parsed results successfully: \(self.searchResults)")
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
            }

            
            // Refresh table view
            // isLoading = false
            // tableView.reloadData()
        }
    }
    
    // Testing advanced search button - using bookmarks button
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar)
    {
        // TO-DO: Figure out a way to make a button display on search bar that
        // is not covered by the cancel button like the bookmarks button is.
        print("The button on the right side of my search bar was pressed")
    }
    
    // UI improvement - unify status bar with search bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - Table View Delegate
extension AllSpellsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Handle no results after a search
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            let cellIdentifier = "SearchResultCell"
            
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            }
            
            if searchResults.count == 0 {
                cell.textLabel!.text = "(Nothing found)"
                cell.detailTextLabel!.text = "(Nothing found - subtitle)"
            } else {
                let searchResult = searchResults[indexPath.row]
                cell.textLabel!.text = searchResult.name
                cell.detailTextLabel!.text = searchResult.school
            }
        
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Prevent selection in certain cases
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
    // MARK: - Helper Methods
    // TO-DO: Implement this method for advanced filtering (user input changes API output)
                // and utilize URL encoding for the Strings
    // Creates the properly encoded API URL to gather spells
    func spellsURL(searchText: String) -> URL {
        // Retrieve all spells
        return URL(string: "https://api.open5e.com/spells/?limit=400")!
    }
    
}

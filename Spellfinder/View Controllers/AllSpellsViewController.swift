//
//  ViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/1/21.
//

import UIKit

// Favoriting protocol
protocol FavoritingSpellsProtocol {
    var isFavorited: Bool { get set }
}

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
    
    // Keep track of our data task so it may be cancelled
    var dataTask: URLSessionDataTask?
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let loadingCell = "LoadingCell"
      }
    }
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if(segmentedControl.selectedSegmentIndex == 1) {
            sortSpells(by: "level")
        } else {
            sortSpells(by: "name")
        }
        
        UserDefaults.standard.set(
            sender.selectedSegmentIndex,
            forKey: "SegmentIndex")
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent search bar from overlapping the table view
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // 94
 
        // Change color of segmented control text
        let themeColor = UIColor(named: "AccentColor")
        UISegmentedControl.appearance().setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: themeColor!], for: .selected)
        
        // Register loading cell nibs
        var cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        // Register UserDefaults defaults
        registerDefaults()
        handleLoadSegment()
        
        // TO-DO: Integrate this with Core Data
        performSearch(firstLoad: true)
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
            message: "There was an error accessing the Open5e API. " +
            "Please try again.",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - User Defaults
    func registerDefaults() {
      let dictionary = [
        "SegmentIndex": 0,
        "FirstTime": true
      ] as [String: Any]
      UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleLoadSegment() {
      let userDefaults = UserDefaults.standard
      let firstTime = userDefaults.bool(forKey: "FirstTime")

      if firstTime {
        // Run code during first launch
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: UIControl.Event.valueChanged)
        userDefaults.set(false, forKey: "FirstTime")
      } else {
        // Set segmented control in accordance with value in UserDefaults
        let segmentIndex = UserDefaults.standard.integer(forKey: "SegmentIndex")
        segmentedControl.selectedSegmentIndex = segmentIndex
        segmentedControl.sendActions(for: UIControl.Event.valueChanged)
      }
    }
}

// MARK: - Search Bar Delegate
extension AllSpellsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(firstLoad: false)
    }
    
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
            searchResults = []
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
                        self.searchResults = self.parse(data: data) // TO-DO: make dict
                        for spell in self.searchResults {
                            print(spell)
                        }
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
    
    // Testing advanced search button - using bookmarks button
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar)
    {
        // TO-DO: Figure out a way to make a button display on search bar that
        // is not covered by the cancel button like the bookmarks button is.
        print("The button on the right side of my search bar was pressed")
    }
    
    // UI improvement - Unify status bar with search bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - Table View Delegate
extension AllSpellsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            // Handle in the middle of searching
            return 1
        } else if !hasSearched {
            // Handle not having searched yet
            return 0
        } else if searchResults.count == 0 {
            // Handle no results after a search
            return 1
        } else {
            // Handle results after a search
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
            let cellIdentifier = TableView.CellIdentifiers.searchResultCell
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath) as! SearchResultCell
            
            if searchResults.count == 0 {
                cell.spellNameLabel.text = "Nothing found"
                cell.levelSchoolLabel.text = "(Nothing found)"
            } else {
                // Fill in the table view cell
                let searchResult = searchResults[indexPath.row]
                cell.spellNameLabel.text = searchResult.name
                cell.levelSchoolLabel.text = searchResult.level! + " " + searchResult.school!
                cell.componentsValueLabel.text = searchResult.components
                cell.durationValueLabel.text = searchResult.duration
                cell.rangeValueLabel.text = searchResult.range
                if searchResult.isConcentration {
                    cell.concentrationValueLabel.textColor = UIColor(named: "AccentColor")
                } else {
                    cell.concentrationValueLabel.textColor = UIColor(named: "GreyColor")
                }
                if searchResult.isRitual {
                    cell.ritualValueLabel.textColor = UIColor(named: "AccentColor")
                } else {
                    cell.ritualValueLabel.textColor = UIColor(named: "GreyColor")
                }
            }
            
            return cell
        }
    }
    
    // UI improvement - Animate the deselection of a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // UI improvement - Prevent selection in certain cases
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
    // UI improvement - change table view cell height to accomodate for XIB
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88;
    }
    
    // MARK: - Navigation
    // TO-DO: Segues/navigaton stuff goes here
    
    
    
    // MARK: - Helper Methods
    // TO-DO: Implement this method for advanced filtering (user input changes API output)
                // and utilize URL encoding for the Strings
    // Creates the properly encoded API URL to gather spells
    func spellsURL(searchText: String) -> URL {
        // Retrieve all spells
        return URL(string: "https://api.open5e.com/spells/?limit=400")!
    }
    
    // Sort spells
    func sortSpells(by: String) -> Void {
        if by == "level" {
            searchResults.sort { $0.levelNum! < $1.levelNum! }
        } else if by == "name" {
            searchResults.sort { $0.name!.localizedStandardCompare($1.name!) == .orderedAscending }
        }
        tableView.reloadData() // TO-DO: Better way?
    }
}

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
    private let search = Search()
    
    var currentSort = "Name"
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
      }
    }
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if(segmentedControl.selectedSegmentIndex == 1) {
            currentSort = "Level"
        } else {
            currentSort = "Name"
        }
        tableView.reloadData()
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
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        // Register UserDefaults defaults
        registerDefaults()
        handleLoadSegment()
        
        // TO-DO: Integrate this with Core Data
        performSearch(firstLoad: true)
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
        currentSort = "Name"
        userDefaults.set(false, forKey: "FirstTime")
      } else {
        // Set segmented control in accordance with value in UserDefaults
        let segmentIndex = UserDefaults.standard.integer(forKey: "SegmentIndex")
        segmentedControl.selectedSegmentIndex = segmentIndex
        segmentedControl.sendActions(for: UIControl.Event.valueChanged)
        if segmentIndex == 0 {
            currentSort = "Name"
        } else {
            currentSort = "Level"
        }
      }
    }
}

// MARK: - Search Bar Delegate
extension AllSpellsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(firstLoad: false)
    }
    
    func performSearch(firstLoad: Bool) {
      search.performSearch(
        for: searchBar.text!,
        category: segmentedControl.selectedSegmentIndex,
        firstLoad: firstLoad) { success in
          if !success {
            self.showNetworkError()
          }
          self.tableView.reloadData()
      }
      
      tableView.reloadData()
      searchBar.resignFirstResponder()
    }
    
    // Testing advanced search button - using bookmarks button
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar)
    {
        // TO-DO: Figure out a way to make a button display on search bar that
        // is not covered by the cancel button like the bookmarks button is.
        print("The button on the right side of my search bar was pressed")
    }
}

// MARK: - Table View Delegate
extension AllSpellsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.isLoading {
            // Handle in the middle of searching
            return 1
        } else if !search.hasSearched {
            // Handle not having searched yet
            return 0
        } else if search.searchResults.count == 0 {
            // Handle no results after a search
            return 1
        } else {
            // Handle results after a search
            return search.searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(
                  withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
                  for: indexPath)
        } else {
            let cellIdentifier = TableView.CellIdentifiers.searchResultCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath) as! SearchResultCell
            
            cell.favoriteButton.addTarget(self, action: #selector(self.favoriteSpell(_:)), for: .touchUpInside)
            
            var searchKey: String
            if currentSort == "Name" {
                searchKey = search.searchResultsKeysByName[indexPath.row]
            } else {
                searchKey = search.searchResultsKeysByLevel[indexPath.row]
            }
            let searchResult = search.searchResultsDict[searchKey]!
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Perform segue to Spell Detail
        let cell = tableView.cellForRow(at: indexPath) as? SearchResultCell
        performSegue(withIdentifier: "ShowSpellDetail", sender: cell)
    }
    
    // UI improvement - Prevent selection in certain cases
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if search.searchResults.count == 0 || search.isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
    // UI improvement - change table view cell height to accomodate for XIB
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowSpellDetail" && sender != nil) {
            // Pass data to next view
            let controller = segue.destination as! DetailSpellViewController
            if let indexPath = tableView.indexPath(
                  for: sender as! SearchResultCell) {
                var searchKey:String
                if currentSort == "Name" {
                    searchKey = search.searchResultsKeysByName[indexPath.row]
                } else {
                    searchKey = search.searchResultsKeysByLevel[indexPath.row]
                }
                controller.searchResultToDisplay = search.searchResultsDict[searchKey]
            }
        }
    }
    
    // MARK: - Data
    // TO-DO: Add favoriting functionality locally and with Core Data
    @objc func favoriteSpell(_ sender: UIButton) {
        print("inside favorite spell button")
    }


}


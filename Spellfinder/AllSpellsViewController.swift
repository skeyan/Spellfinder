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
    
    // Store our search results
    var searchResults = [String]()
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
        tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
 
        // Change color of segmented control text
        let themeColor = UIColor(red: 27/255, green: 181/255, blue: 242/255, alpha: 1)
        UISegmentedControl.appearance().setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: themeColor], for: .selected)
        
        // TO-DO: Use URLSession to get all spells from API
    }
}

// MARK: - Search Bar Delegate
extension AllSpellsViewController: UISearchBarDelegate {
    // TO-DO: Make search call API and display results
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Debug
        print("The search text is '\(searchBar.text!)'")
        
        // Perform search
        if !searchBar.text!.isEmpty {
            // Remove keyboard after search is performed
            searchBar.resignFirstResponder()
            
            // Get all spells from the API
            searchResults = []
            for i in 0...2 {
                searchResults.append(String(format:"Fake Results %d for '%@'", i, searchBar.text!))
            }
            
            // Refresh table view
            tableView.reloadData()
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
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.textLabel!.text = searchResults[indexPath.row]
        return cell
    }
    
}

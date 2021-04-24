//
//  SearchResultsViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
        static let searchResultHeaderCell = "SearchResultHeaderCell"
        static let filtersUsedCell = "FiltersUsedCell"
      }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register nibs
        // TO-DO: nothingFound, loadingCell
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultHeaderCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultHeaderCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.filtersUsedCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.filtersUsedCell)
        
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            // TO-DO: Return with dynamic count of search results
            return 10
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Search Results Header
            let cellIdentifier = TableView.CellIdentifiers.searchResultHeaderCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            return cell
        case 1:
            // Filter
            let cellIdentifier = TableView.CellIdentifiers.filtersUsedCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            let filterDescription = cell.viewWithTag(101) as! UILabel
            filterDescription.sizeToFit()
            return cell
        case 2:
            // Search Results
            let cellIdentifier = TableView.CellIdentifiers.searchResultCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            return cell
        default:
            let cellIdentifier = TableView.CellIdentifiers.searchResultCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 44
        case 1:
            return 68
        case 2:
            return 88
        default:
            return 88
        }
    }
}

//
//  SearchResultsViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    @IBOutlet var staticTableView: UITableView!
    @IBOutlet var tableView: UITableView!
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
      }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register nibs
        let cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        // TO-DO: Replace with Search and Filter cells
        staticTableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === staticTableView {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === staticTableView {
            return 1
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === staticTableView {
            let cellIdentifier = TableView.CellIdentifiers.searchResultCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            cell.backgroundColor = UIColor.yellow
            return cell
        } else {
            let cellIdentifier = TableView.CellIdentifiers.searchResultCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            return cell
        }
    }
    
    // UI improvement - change table view cell height to accomodate for XIB
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === staticTableView {
            return 60
        } else {
            return 88
        }
    }
  
}

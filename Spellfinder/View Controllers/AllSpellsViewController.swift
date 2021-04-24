//
//  ViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/1/21.
//

import UIKit
import CoreData

// Favoriting protocol
protocol FavoritingSpellsDelegate {
    var isFavorited: Bool { get set }
}

class AllSpellsViewController: UIViewController, SearchResultCellDelegate {
    
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
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    var coreDataSpells = [Spell]()

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
        
        // Load the spells from the API & from CoreData
        fetchSpells()
        performSearch(firstLoad: true, coreDataSpells: self.coreDataSpells)
    }
    
    // Get spells from CoreData
    func fetchSpells() {
        do {
            // Get all Spell objects in Core Data
            self.coreDataSpells = try managedObjectContext.fetch(Spell.fetchRequest()) 
            
        } catch {
            fatalError("Error: \(error)")
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
    // TO-DO: Put the results, filtered, into a new screen with a separate table view
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "ShowSearchResults", sender: nil)
        // performSearch(firstLoad: false)
    }
    
    func performSearch(firstLoad: Bool, coreDataSpells: [Spell]) {
      search.performSearch(
        for: searchBar.text!,
        firstLoad: firstLoad,
        coreDataSpells: coreDataSpells) { success in
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
            
            cell.delegate = self
            
            // Get the data to display in the search result cell
            var searchKey: String
            if currentSort == "Name" {
                searchKey = search.searchResultsKeysByName[indexPath.row]
            } else {
                searchKey = search.searchResultsKeysByLevel[indexPath.row]
            }
            let searchResult = search.searchResultsDict[searchKey]!
            
            cell.configure(for: searchResult)
            
            cell.data = searchResult
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Detail spell view
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
    
    // MARK: - Core Data
    // TO-DO: Add favoriting functionality locally and with Core Data
    func favoritesButtonTapped(cell: SearchResultCell) {
        print("-- inside favorite spell button")
        // Save the spell entity if that spell doesn't already exist in Core Data
        // Otherwise, if that spell is in Core Data, delete it (unfavorite it)
        if !(someEntityExists(slug: cell.data.slug!)) {
            // Create the spell entity
            let spellToSave = Spell(context: managedObjectContext)
            spellToSave.archetype = cell.data.archetype
            spellToSave.castingTime = cell.data.castingTime
            spellToSave.circles = cell.data.circles
            spellToSave.components = cell.data.components
            spellToSave.concentration = cell.data.concentration
            spellToSave.desc = cell.data.desc
            spellToSave.dndClass = cell.data.dndClass
            spellToSave.duration = cell.data.duration
            spellToSave.higherLevelDesc = cell.data.higherLevelDesc
            spellToSave.isConcentration = cell.data.isConcentration
            spellToSave.isRitual = cell.data.isRitual
            spellToSave.level = cell.data.level
            spellToSave.levelNum = cell.data.levelNum!
            spellToSave.material = cell.data.material
            spellToSave.name = cell.data.name
            spellToSave.page = cell.data.page
            spellToSave.range = cell.data.range
            spellToSave.ritual = cell.data.ritual
            spellToSave.school = cell.data.school
            spellToSave.slug = cell.data.slug
            
            // Update local instance array for table
            search.searchResultsDict[cell.data.slug!]!.isFavorited = !search.searchResultsDict[cell.data.slug!]!.isFavorited
            cell.data.isFavorited = search.searchResultsDict[cell.data.slug!]!.isFavorited
            // Update core data
            spellToSave.isFavorited = cell.data.isFavorited
            
            do {
               try managedObjectContext.save()
            } catch {
                fatalError("Error: \(error)")
            }
        } else {
            // Update local instance array for table
            search.searchResultsDict[cell.data.slug!]!.isFavorited = !search.searchResultsDict[cell.data.slug!]!.isFavorited
            cell.data.isFavorited = search.searchResultsDict[cell.data.slug!]!.isFavorited
            
            // Update core data
            let spellToDelete = retrieveSpell(slug: cell.data.slug!)
            self.managedObjectContext.delete(spellToDelete!)
            
            do {
               try managedObjectContext.save()
            } catch {
                fatalError("Error: \(error)")
            }
        }
        
        // Update cell UI
        if(cell.data.isFavorited) {
            let image = UIImage(systemName: "star.fill")
            cell.favoriteButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(systemName: "star")
            cell.favoriteButton.setImage(image, for: .normal)
        }
        
        print("End of favorites button function")
    }
    
    // MARK: - Core Data Helpers
    func retrieveSpell(slug: String) -> Spell? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Spell")
        fetchRequest.predicate = NSPredicate(format: "slug = %@", slug)
        
        var results: [NSManagedObject] = []

        do {
            results = try managedObjectContext.fetch(fetchRequest)
        }
        catch {
            print("Error executing fetch request: \(error)")
        }

        if results.count != 0 {
            return results[0] as? Spell
        } else {
            return nil
        }
    }
    
    func someEntityExists(slug: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Spell")
        fetchRequest.predicate = NSPredicate(format: "slug = %@", slug)
        
        var results: [NSManagedObject] = []

        do {
            results = try managedObjectContext.fetch(fetchRequest)
        }
        catch {
            print("Error executing fetch request: \(error)")
        }

        return results.count > 0
    }
}


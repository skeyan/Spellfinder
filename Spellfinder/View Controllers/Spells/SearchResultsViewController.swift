//
//  SearchResultsViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/17/21.
//

import UIKit
import CoreData

class SearchResultsViewController: UIViewController, SearchResultCellDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: - Instance Variables
    var searchedText: String = ""
    var usedFilters: String = "Level: Any, Classes: Any, Components: Any, School: Any, Concentration: Any"
    
    var allSpellsViewController = AllSpellsViewController()
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
        static let filtersUsedCell = "FiltersUsedCell"
      }
    }
    
    let search = Search()
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    var coreDataSpells = [Spell]()
    
    // MARK: - Actions
    @IBAction func didPressFilterButton(_ sender: Any) {
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let viewController = navController.viewControllers[navController.viewControllers.count - 2]
            if viewController is SearchFilterViewController {
                let tmp = viewController as! SearchFilterViewController
                tmp.searchBar.text = searchBar.text
                navigationController?.popViewController(animated: true)
            } else if viewController is AllSpellsViewController {
                performSegue(withIdentifier: "GoToFilters", sender: self)
            }
        }
    }
    
    // MARK: - Search Result Delegate
    func favoritesButtonTapped(cell: SearchResultCell) {
        // Save the spell entity if that spell doesn't already exist in Core Data
        // Otherwise, if that spell is in Core Data, unfavorite it
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
            
            // Update all spells instance array for table
            allSpellsViewController.search.searchResultsDict[cell.data.slug!]!.isFavorited = !allSpellsViewController.search.searchResultsDict[cell.data.slug!]!.isFavorited
            allSpellsViewController.tableView.reloadData()
            
            // Update core data
            spellToSave.isFavorited = cell.data.isFavorited
            
            do {
               try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        } else {
            // Update local instance array for table
            search.searchResultsDict[cell.data.slug!]!.isFavorited = !search.searchResultsDict[cell.data.slug!]!.isFavorited
            cell.data.isFavorited = search.searchResultsDict[cell.data.slug!]!.isFavorited
            
            // Update all spells instance array for table
            allSpellsViewController.search.searchResultsDict[cell.data.slug!]!.isFavorited = !allSpellsViewController.search.searchResultsDict[cell.data.slug!]!.isFavorited
            allSpellsViewController.tableView.reloadData()
            
            // Update core data
            let spellToUpdate = retrieveSpell(slug: cell.data.slug!)
            
            if let character = spellToUpdate!.character {
                if (character.count == 0) {
                    managedObjectContext.delete(spellToUpdate!)
                } else {
                    spellToUpdate!.isFavorited = !spellToUpdate!.isFavorited
                }
            } else {
                spellToUpdate!.isFavorited = !spellToUpdate!.isFavorited
            }
            
            do {
               try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
        
        // Update cell UI
        if(cell.data.isFavorited) {
            let image = UIImage(named: "star-filled")
            cell.favoriteButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: "star")
            cell.favoriteButton.setImage(image, for: .normal)
        }
    }
    
    func addButtonTapped(cell: SearchResultCell) {
        performSegue(withIdentifier: "SelectCharacterFromResults", sender: cell)
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register nibs
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.filtersUsedCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.filtersUsedCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        // Gesture recognizer to dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.cancelsTouchesInView = false // allow row selection
        self.view.addGestureRecognizer(tapGesture)
        
        // Dismiss keyboard when dragging/scrolling through spells' table view
        tableView.keyboardDismissMode = .onDrag
        
        // Remove 1px bottom from search bar
        searchBar.backgroundImage = UIImage()
        
        // Fill in search bar text
        searchBar.text = searchedText
        
        // Load the spells from the API & from CoreData
        fetchSpells()
        performSearch(firstLoad: false, coreDataSpells: self.coreDataSpells)
    }
    
    // UI improvement - dismiss the keyboard when tapping out of a text field
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
    }
    
    // Display network error to user
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an network error. " +
            "Please try again.",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Get spells from CoreData
    func fetchSpells() {
        do {
            // Get all Spell objects in Core Data
            self.coreDataSpells = try managedObjectContext.fetch(Spell.fetchRequest())
            
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // 'Sync' search bar text when changed
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if (parent == nil) {
            if let navController = self.navigationController, navController.viewControllers.count >= 2 {
                let viewController = navController.viewControllers[navController.viewControllers.count - 2]
                if viewController is AllSpellsViewController {
                    let tmp = viewController as! AllSpellsViewController
                    tmp.searchBar.text = searchBar.text
                } else if viewController is SearchFilterViewController {
                    let tmp = viewController as! SearchFilterViewController
                    tmp.searchBar.text = searchBar.text
                }
            }
        }
    }
}

// MARK: - Search Bar Delegate
extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        fetchSpells()
        performSearch(firstLoad: false, coreDataSpells: self.coreDataSpells)
    }
    
    func performSearch(firstLoad: Bool, coreDataSpells: [Spell]?) {
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
}

// MARK: - Table View Delegate
extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Dynamic search results
        if section == 1 {
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
        } else { // Filters
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Filter
            let cellIdentifier = TableView.CellIdentifiers.filtersUsedCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            let filterDescription = cell.viewWithTag(101) as! UILabel
            filterDescription.sizeToFit()
            filterDescription.text = usedFilters
            return cell
        case 1:
            // Search Results
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
                let searchKey = search.searchResultsKeysByName[indexPath.row]
                let searchResult = search.searchResultsDict[searchKey]!

                cell.configure(for: searchResult)
                
                cell.data = searchResult
                
                return cell
            }
        default:
            let cellIdentifier = TableView.CellIdentifiers.searchResultCell
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as? SearchResultCell
        performSegue(withIdentifier: "ShowSpellFromSearchResults", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 68
        case 1:
            return 88
        default:
            return 88
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? nil : indexPath
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SelectCharacterFromResults" && sender != nil) {
            // Pass data to next view
            let controller = segue.destination as! SelectCharacterViewController
            
            // Spell to add
            if let indexPath = tableView.indexPath(
                  for: sender as! SearchResultCell) {
                let searchKey = search.searchResultsKeysByName[indexPath.row]
                controller.spellToAdd = search.searchResultsDict[searchKey]
            }
                
            // Core data and Characters
            controller.managedObjectContext = managedObjectContext
            var currentCharacters: [Character] = []
            do {
                // Get all current Character objects in Core Data
                currentCharacters = try managedObjectContext.fetch(Character.fetchRequest())
            } catch {
                fatalCoreDataError(error)
            }
            controller.currentCharacters = currentCharacters
        }
        
        // Detail spell view
        if (segue.identifier == "ShowSpellFromSearchResults" && sender != nil) {
            // Pass data to next view
            let controller = segue.destination as! DetailSpellViewController
            if tableView.indexPath(for: sender as! SearchResultCell) != nil {
                let cell = sender as! SearchResultCell
                controller.searchResultToDisplay = allSpellsViewController.search.searchResultsDict[cell.data.slug!]
            }
        }
        
        if (segue.identifier == "GoToFilters" && sender != nil) {
            let controller = segue.destination as! SearchFilterViewController
            controller.allSpellsViewController = allSpellsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let searchText = searchBar.text {
                if !(searchText.isEmpty) {
                    controller.searchText = searchText
                }
            }
            
            // Restore filters if they exist
            if let filters = search.filters {
                // Data
                controller.levelFilters = filters.levelIndex
                controller.classFilters = filters.classIndexes
                controller.componentsFilters = filters.componentsIndexes
                controller.schoolFilters = filters.schoolIndex
                controller.concentrationFilters = filters.concentrationIndex
                
                // Labels
                controller.levelText = filters.levelString
                controller.classText = filters.classString
                controller.componentsText = filters.componentsString
                controller.schoolText = filters.schoolString
                controller.concentrationText = filters.concentrationString
            }
        }
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
            fatalCoreDataError(error)
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
            fatalCoreDataError(error)
        }

        return results.count > 0
    }
}


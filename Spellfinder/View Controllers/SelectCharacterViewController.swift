//
//  SelectCharacterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/26/21.
//

import UIKit
import CoreData

class SelectCharacterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Instance Variables
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    var spellToAdd: SearchResult?
    var charactersToAddSpellTo: [Character] = []
    
    var currentCharacters: [Character]?
    var dataModel: [Entity] = []
    
    struct TableView {
      struct CellIdentifiers {
        static let characterCell = "CharacterCell"
      }
    }
    
    struct Entity {
        var myCharacter: Character
        var isSelected: Bool
    }
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        // TO-DO: Add spell to character(s) in CoreData
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nibs
        let cellNib = UINib(nibName: TableView.CellIdentifiers.characterCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.characterCell)
        
        for character in currentCharacters! {
            let entity = Entity(myCharacter: character, isSelected: false)
            dataModel.append(entity)
        }
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return dataModel.count
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.characterCell, for: indexPath) as! CharacterCell

        // Configure the cell...
        cell.configure(for: (currentCharacters![indexPath.row]))
        if (dataModel[indexPath.row].isSelected == true) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        dataModel[indexPath.row].isSelected = !dataModel[indexPath.row].isSelected
        tableView.reloadData()
    }
}

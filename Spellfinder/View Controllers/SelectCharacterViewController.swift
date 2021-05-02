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
        for entity in dataModel {
            if (entity.isSelected) {
                // Create or update spell depending if it exists or not, to be saved
                var spellToSave: Spell
                if !(someEntityExists(slug: spellToAdd!.slug!)) {
                    // Create the spell entity
                    spellToSave = Spell(context: managedObjectContext)
                    spellToSave.archetype = spellToAdd!.archetype
                    spellToSave.castingTime = spellToAdd!.castingTime
                    spellToSave.circles = spellToAdd!.circles
                    spellToSave.components = spellToAdd!.components
                    spellToSave.concentration = spellToAdd!.concentration
                    spellToSave.desc = spellToAdd!.desc
                    spellToSave.dndClass = spellToAdd!.dndClass
                    spellToSave.duration = spellToAdd!.duration
                    spellToSave.higherLevelDesc = spellToAdd!.higherLevelDesc
                    spellToSave.isConcentration = spellToAdd!.isConcentration
                    spellToSave.isRitual = spellToAdd!.isRitual
                    spellToSave.level = spellToAdd!.level
                    spellToSave.levelNum = spellToAdd!.levelNum!
                    spellToSave.material = spellToAdd!.material
                    spellToSave.name = spellToAdd!.name
                    spellToSave.page = spellToAdd!.page
                    spellToSave.range = spellToAdd!.range
                    spellToSave.ritual = spellToAdd!.ritual
                    spellToSave.school = spellToAdd!.school
                    spellToSave.slug = spellToAdd!.slug
                    spellToSave.isFavorited = spellToAdd!.isFavorited
                } else {
                    // Retrieve existing spell
                    spellToSave = retrieveSpell(slug: spellToAdd!.slug!)!
                }
                
                // Add the spell to the selected character
                 entity.myCharacter.addToSpells(spellToSave)
            }
        }
        
        // Save context
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register nibs
        let cellNib = UINib(nibName: TableView.CellIdentifiers.characterCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.characterCell)
        
        for character in currentCharacters! {
            var shouldBeSelected = false
            let spellInCharacter = character.spells?.filter { ($0 as! Spell).slug! == spellToAdd!.slug! }
            if let spell = spellInCharacter {
                if (spell.count > 0) {
                    shouldBeSelected = true
                }
            }
            
            let entity = Entity(myCharacter: character, isSelected: shouldBeSelected)
            dataModel.append(entity)
        }
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return dataModel.count
        default:
            return 1
        }
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhichSpellToAddCell", for: indexPath)
            cell.textLabel!.text = "Spell: " + (spellToAdd?.name)!
            return cell
        }
        
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
        switch indexPath.section {
        case 0:
            return 44
        case 1:
            return 88
        default:
            return 88
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        dataModel[indexPath.row].isSelected = !dataModel[indexPath.row].isSelected
        tableView.reloadData()
    }
    
    // UI improvement - Prevent selection in certain cases
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? nil : indexPath
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

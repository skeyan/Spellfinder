//
//  AllCharactersViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit
import CoreData

class AllCharactersViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var addCharacterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Instance Variables
    struct TableView {
      struct CellIdentifiers {
        static let characterCell = "CharacterCell"
      }
    }
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController<Character> = {
      let fetchRequest = NSFetchRequest<Character>()

      let entity = Character.entity()
      fetchRequest.entity = entity

      let sortDescriptor = NSSortDescriptor(
        key: "name",
        ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor]

      fetchRequest.fetchBatchSize = 20

      let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: self.managedObjectContext,
        sectionNameKeyPath: nil,
        cacheName: "Characters")

      fetchedResultsController.delegate = self
      return fetchedResultsController
    }()
    
    // MARK: - Actions
    @IBAction func addCharacterWasPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = CGAffineTransform.identity
                    self.performSegue(withIdentifier: "AddCharacter", sender: self)
            }
        })
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register nibs
        let cellNib = UINib(nibName: TableView.CellIdentifiers.characterCell, bundle: nil)
        tableView.register(cellNib,forCellReuseIdentifier: TableView.CellIdentifiers.characterCell)

        // UI
        addCharacterButton.applyGradient(colors: [Helper.UIColorFromRGB(0x2CD0DD).cgColor, Helper.UIColorFromRGB(0xBB4BD2).cgColor])
        
        // Get characters from Core Data
        fetchCharacters()
    }
    
    deinit {
      fetchedResultsController.delegate = nil
    }
    
    // MARK: - Core Data
    func fetchCharacters() {
      do {
        try fetchedResultsController.performFetch()
      } catch {
        fatalCoreDataError(error)
      }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        // TO-DO: Prepare segue to Detail Character
    }
}

// MARK: - Table View Delegate
extension AllCharactersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.characterCell) as! CharacterCell
        
        // Get the data to display in the character cell from Core Data
        let character = fetchedResultsController.object(at: indexPath)
        cell.configure(for: character)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TO-DO: Perform segue to Character Detail
        self.performSegue(withIdentifier: "ShowCharacterDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(
        _ tableView: UITableView,
        accessoryButtonTappedForRowWith indexPath: IndexPath
    ) {
        // Create the view controller object for the Add/Edit Character screen
        // and push onto navigation stack
        let controller = storyboard!.instantiateViewController(
            withIdentifier: "AddCharacterViewController") as! AddCharacterViewController
        // we added the storyboardID via the storyboard
        // controller.delegate = self
        
        // TO-DO: Set characterToEdit
        // let checklist = dataModel.lists[indexPath.row]
        // controller.checklistToEdit = checklist
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension AllSpellsViewController: AddCharacterViewControllerDelegate {
    func addCharacterViewControllerDidCancel(_ controller: AddCharacterViewController) {
        print("cancelled character")
        navigationController?.popViewController(animated: true)
    }
    
    func addCharacterViewController(_ controller: AddCharacterViewController, didFinishAdding character: Character) {
        print("added character")
        navigationController?.popViewController(animated: true)
    }
    
    func addCharacterViewController(_ controller: AddCharacterViewController, didFinishEditing character: Character) {
        print("edited character")
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - NSFetchedResults Controller Delegate
extension AllSpellsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
      print("*** controllerWillChangeContent")
      tableView.beginUpdates()
    }

    func controller(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>,
      didChange anObject: Any,
      at indexPath: IndexPath?,
      for type: NSFetchedResultsChangeType,
      newIndexPath: IndexPath?
    ) {
      switch type {
      case .insert:
        print("*** NSFetchedResultsChangeInsert (object)")
        tableView.insertRows(at: [newIndexPath!], with: .fade)

      case .delete:
        print("*** NSFetchedResultsChangeDelete (object)")
        tableView.deleteRows(at: [indexPath!], with: .fade)

      case .update:
        print("*** NSFetchedResultsChangeUpdate (object)")
        if let cell = tableView.cellForRow(
          at: indexPath!) as? CharacterCell {
          let character = controller.object(
            at: indexPath!) as! Character
          cell.configure(for: character)
        }

      case .move:
        print("*** NSFetchedResultsChangeMove (object)")
        tableView.deleteRows(at: [indexPath!], with: .fade)
        tableView.insertRows(at: [newIndexPath!], with: .fade)
        
      @unknown default:
        print("*** NSFetchedResults unknown type")
      }
    }

    func controller(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>,
      didChange sectionInfo: NSFetchedResultsSectionInfo,
      atSectionIndex sectionIndex: Int,
      for type: NSFetchedResultsChangeType
    ) {
      switch type {
      case .insert:
        print("*** NSFetchedResultsChangeInsert (section)")
        tableView.insertSections(
          IndexSet(integer: sectionIndex), with: .fade)
      case .delete:
        print("*** NSFetchedResultsChangeDelete (section)")
        tableView.deleteSections(
          IndexSet(integer: sectionIndex), with: .fade)
      case .update:
        print("*** NSFetchedResultsChangeUpdate (section)")
      case .move:
        print("*** NSFetchedResultsChangeMove (section)")
      @unknown default:
        print("*** NSFetchedResults unknown type")
      }
    }

    func controllerDidChangeContent(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
      print("*** controllerDidChangeContent")
      tableView.endUpdates()
    }
}

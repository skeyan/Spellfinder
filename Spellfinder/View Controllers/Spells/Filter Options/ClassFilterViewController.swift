//
//  ClassFilterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 5/3/21.
//

import UIKit

protocol ClassFilterViewControllerDelegate: class {
  func classFilterPicker(
    _ picker: ClassFilterViewController,
    didPickIndexes indexes: Set<Int>,
    didPickClass dndClasses: [String]
  )
}
class ClassFilterViewController: UITableViewController {
    
    // MARK: - Instance Variables
    let classes = [
        "Any",
        "Bard", "Cleric",
        "Druid", "Paladin",
        "Ranger", "Sorcerer",
        "Warlock", "Wizard"
    ]

    /*
    Selecting a number of different classes means you want spells that
    can be learned by ALL of those classes (but not limited to them).
    Eg. Selecting "Wizard" and "Warlock" means the spell search results
    will contain at least both Wizard and Warlock in their class tags,
    selecting "Any" ignores class tags for spells, and
    selecting "Wizard" will give spell search results that contain Wizard
    (among with possibly others) in their class tags.
    */
    struct MyClass {
        var myClass: String
        var isSelected: Bool
    }
    var selectedClasses: Set<Int> = [] // contains indexes of all selected items
    var dataModel: [MyClass] = []
    
    weak var delegate: ClassFilterViewControllerDelegate?
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        var pickedClasses: [String] = []
        
        for c in selectedClasses {
            pickedClasses.append(dataModel[c].myClass)
        }
        
        if pickedClasses.count != 0 {
            delegate?.classFilterPicker(self, didPickIndexes: selectedClasses, didPickClass: pickedClasses)
        } else {
            delegate?.classFilterPicker(self, didPickIndexes: [0], didPickClass: ["Any"])
        }
                
        navigationController?.popViewController(animated: true)
    }

    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up data model
        for c in classes {
            let newClass = MyClass(myClass: c, isSelected: false)
            dataModel.append(newClass)
        }
        for c in selectedClasses {
            dataModel[c].isSelected = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassFilterOptionCell", for: indexPath)

        // Configure the cell...
        if (dataModel[indexPath.row].isSelected == true) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel!.text = dataModel[indexPath.row].myClass

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Mark the selected options...
        let selectedClass = indexPath.row
        if dataModel[selectedClass].isSelected { // Deselect an option
            selectedClasses.remove(selectedClass)
            dataModel[selectedClass].isSelected = false
        } else if selectedClass == 0 { // Select Any
            for c in selectedClasses {
                dataModel[c].isSelected = false
            }
            selectedClasses.removeAll()
            selectedClasses.insert(selectedClass)
            dataModel[selectedClass].isSelected = true
        } else { // Select Else
            if selectedClasses.contains(0) {
                selectedClasses.remove(0)
                dataModel[0].isSelected = false
            }

            selectedClasses.insert(selectedClass)
            dataModel[selectedClass].isSelected = true
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

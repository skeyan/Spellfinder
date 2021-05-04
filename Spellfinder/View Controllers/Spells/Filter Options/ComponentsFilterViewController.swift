//
//  ComponentsFilterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 5/3/21.
//

import UIKit

protocol ComponentsFilterViewControllerDelegate: class {
  func componentsFilterPicker(
    _ picker: ComponentsFilterViewController,
    didPickIndexes indexes: Set<Int>,
    didPickComponents components: [String]
  )
}
class ComponentsFilterViewController: UITableViewController {
    // MARK: - Instance Variables
    let components = [
        "Any",
        "V",
        "S",
        "M"
    ]
    
    /*
    Selecting a number of different components means you want
    spells that requires all of those components, and maybe more.
    Eg. Selecting "V" and "S" gives you spells that require both V and S,
    and maybe also M,
    selecting "V" gives you spells that require at least V, and
    selecting "Any" ignores spells requirements.
    */
    struct Component {
        var component: String
        var isSelected: Bool
    }
    var selectedComponents: Set<Int> = [] // contains indexes of all selected items
    var dataModel: [Component] = []
    weak var delegate: ComponentsFilterViewControllerDelegate?
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        var pickedComponents: [String] = []
        
        for c in selectedComponents {
            pickedComponents.append(dataModel[c].component)
        }
               
        if pickedComponents.count != 0 {
            delegate?.componentsFilterPicker(self, didPickIndexes: selectedComponents, didPickComponents: pickedComponents)
        } else {
            delegate?.componentsFilterPicker(self, didPickIndexes: [0], didPickComponents: ["Any"])
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up data model
        for component in components {
            let newComponent = Component(component: component, isSelected: false)
            dataModel.append(newComponent)
        }
        for c in selectedComponents {
            dataModel[c].isSelected = true
        }
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComponentsFilterOptionCell", for: indexPath)

        // Configure the cell...
        if (dataModel[indexPath.row].isSelected == true) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel!.text = dataModel[indexPath.row].component

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Mark the selected options...
        let selectedComponent = indexPath.row
        if dataModel[selectedComponent].isSelected { // Deselect an option
            selectedComponents.remove(selectedComponent)
            dataModel[selectedComponent].isSelected = false
        } else if selectedComponent == 0 { // Select Any
            for c in selectedComponents {
                dataModel[c].isSelected = false
            }
            selectedComponents.removeAll()
            selectedComponents.insert(selectedComponent)
            dataModel[selectedComponent].isSelected = true
        } else { // Select Else
            if selectedComponents.contains(0) {
                selectedComponents.remove(0)
                dataModel[0].isSelected = false
            }

            selectedComponents.insert(selectedComponent)
            dataModel[selectedComponent].isSelected = true
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

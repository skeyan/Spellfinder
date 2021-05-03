//
//  SchoolFilterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 5/3/21.
//

import UIKit

protocol SchoolFilterViewControllerDelegate: class {
  func schoolPicker(
    _ picker: SchoolFilterViewController,
    didPickIndex index: Int,
    didPickSchool school: String
  )
}
class SchoolFilterViewController: UITableViewController {
    
    // MARK: - Instance Variables
    let schools = [
        "Any",
        "Abjuration",
        "Conjuration",
        "Divination",
        "Enchantment",
        "Evocation",
        "Illusion",
        "Necromancy",
        "Transmutation"
    ]
    
    var selectedSchool: Int = 0 // index of dataModel
    var dataModel: [School] = []
    
    struct School {
        var school: String
        var isSelected: Bool
    }
    
    weak var delegate: SchoolFilterViewControllerDelegate?
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        if let delegate = delegate {
            delegate.schoolPicker(self, didPickIndex: selectedSchool, didPickSchool: dataModel[selectedSchool].school)
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        for school in schools {
            let newSchool = School(school: school, isSelected: false)
            dataModel.append(newSchool)
        }
        dataModel[selectedSchool].isSelected = true
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }

    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolFilterOptionCell", for: indexPath)

        // Configure the cell...
        if (dataModel[indexPath.row].isSelected == true) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel!.text = dataModel[indexPath.row].school
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        dataModel[selectedSchool].isSelected = false
        selectedSchool = indexPath.row
        dataModel[selectedSchool].isSelected = true

        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

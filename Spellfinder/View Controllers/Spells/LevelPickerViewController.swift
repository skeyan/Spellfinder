//
//  LevelPickerViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 5/2/21.
//

import UIKit
import CoreData

protocol LevelPickerViewControllerDelegate: class {
  func levelPicker(
    _ picker: LevelPickerViewController,
    didPickLevel level: String
  )
}
class LevelPickerViewController: UITableViewController {
    // MARK: - Instance Variables
    let levels = [
      "All Levels", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
    ]
    var selectedLevel: Int = 0 // index of dataModel
    var dataModel: [Level] = []
    
    struct Level {
        var level: String
        var isSelected: Bool
    }
    
    weak var delegate: LevelPickerViewControllerDelegate?
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        if let delegate = delegate {
            delegate.levelPicker(self, didPickLevel: dataModel[selectedLevel].level)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for level in levels {
            let newLevel = Level(level: level, isSelected: false)
            dataModel.append(newLevel)
        }
        dataModel[selectedLevel].isSelected = true
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LevelFilterOptionCell", for: indexPath)

        // Configure the cell...
        if (dataModel[indexPath.row].isSelected == true) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel!.text = dataModel[indexPath.row].level

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        dataModel[selectedLevel].isSelected = false
        selectedLevel = indexPath.row
        dataModel[selectedLevel].isSelected = true
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

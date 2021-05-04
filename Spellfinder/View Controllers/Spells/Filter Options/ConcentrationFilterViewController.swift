//
//  ConcentrationFilterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 5/3/21.
//

import UIKit

protocol ConcentrationFilterViewControllerDelegate: class {
  func concentrationPicker(
    _ picker: ConcentrationFilterViewController,
    didPickIndex index: Int,
    didPickConcentration concentration: String
  )
}
class ConcentrationFilterViewController: UITableViewController {
    
    // MARK: - Instance Variables
    let concentrations = [
        "Any",
        "Yes",
        "No"
    ]
    
    var selectedConcentration: Int = 0 // index of dataModel
    var dataModel: [Concentration] = []
    
    struct Concentration {
        var concentration: String
        var isSelected: Bool
    }
    
    weak var delegate: ConcentrationFilterViewControllerDelegate?
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        if let delegate = delegate {
            delegate.concentrationPicker(self, didPickIndex: selectedConcentration, didPickConcentration: dataModel[selectedConcentration].concentration)
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        for concentration in concentrations {
            let newConcentration = Concentration(concentration: concentration, isSelected: false)
            dataModel.append(newConcentration)
        }
        dataModel[selectedConcentration].isSelected = true
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return concentrations.count
    }

    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConcentrationFilterOptionCell", for: indexPath)

        // Configure the cell...
        if (dataModel[indexPath.row].isSelected == true) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel!.text = dataModel[indexPath.row].concentration

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        dataModel[selectedConcentration].isSelected = false
        selectedConcentration = indexPath.row
        dataModel[selectedConcentration].isSelected = true

        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

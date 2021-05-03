//
//  SearchFilterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/29/21.
//

import UIKit

class SearchFilterViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var levelFilterValueLabel: UILabel!
    @IBOutlet weak var classFilterValueLabel: UILabel!
    @IBOutlet weak var componentsFilterValueLabel: UILabel!
    @IBOutlet weak var schoolFilterValueLabel: UILabel!
    @IBOutlet weak var concentrationFilterValueLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    // MARK: - Instance Variables
    var levelFilters: Int?
    var classFilters: Set<Int>?
    var componentsFilters: Set<Int>?
    
    // MARK: - Actions
    @IBAction func searchButtonWasTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = CGAffineTransform.identity
                    
                    // TO-DO: Segue to search results and give proper filters
            }
        })
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        searchButton.applyGradient(colors: [Helper.UIColorFromRGB(0x2CD0DD).cgColor, Helper.UIColorFromRGB(0xBB4BD2).cgColor])
        
        // Gesture recognizer to dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.cancelsTouchesInView = false // allow row selection
        self.view.addGestureRecognizer(tapGesture)
        
        // Scroll table section headers like a regular cell
        let dummyViewHeight = CGFloat(50)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        // Remove 1px bottom border from search bar
        searchBar.backgroundImage = UIImage()
    }
    
    // UI improvement - dismiss the keyboard when tapping out of a text field
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 5 ? 2 : 1
    }
    
    // MARK: - Table View Delegates
    // UI improvement - disable highlighting of rows in certain cases
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 5 && indexPath.row == 1) {
            return false
        }
        if (indexPath.section == 0) {
            return false
        }
        return true
    }
    
    // UI improvement - Make custom layout for section headers
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white

        let sectionLabel = UILabel(frame: CGRect(x: 20, y: 18, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        sectionLabel.font = UIFont(name: "Retroica", size: 18)
        sectionLabel.textColor = UIColor.black
        sectionLabel.text = ""
        switch section {
        case 0:
            sectionLabel.text = ""
        case 1:
            sectionLabel.text = "Filter by level"
        case 2:
            sectionLabel.text = "Filter by class"
        case 3:
            sectionLabel.text = "Filter by components"
        case 4:
            sectionLabel.text = "Filter by school of magic"
        case 5:
            sectionLabel.text = "Concentration"
        default:
            sectionLabel.text = ""
        }
        
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)

        return headerView
    }
    
    // UI improvement - make the section headers taller
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat(0) : CGFloat(40)
    }
    
    // UI improvement - animate the deselection of rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Level
        if (segue.identifier == "ChooseLevelFilter" && sender != nil) {
            let controller = segue.destination as! LevelPickerViewController
            controller.delegate = self
            if levelFilterValueLabel.text == "Any" {
                controller.selectedLevel = 0
            } else {
                if let filter = levelFilters {
                    controller.selectedLevel = filter
                }
            }
        }
        
        // Class
        if (segue.identifier == "ChooseClassFilter" && sender != nil) {
            let controller = segue.destination as! ClassFilterViewController
            controller.delegate = self
            if classFilterValueLabel.text == "Any" {
                controller.selectedClasses = [0]
            } else {
                if let filter = classFilters {
                    controller.selectedClasses = filter
                }
            }
        }
        
        // Components
        if (segue.identifier == "ChooseComponentsFilter" && sender != nil) {
            let controller = segue.destination as! ComponentsFilterViewController
            controller.delegate = self
            if componentsFilterValueLabel.text == "Any" {
                controller.selectedComponents = [0]
            } else {
                if let filter = componentsFilters {
                    controller.selectedComponents = filter
                }
            }
        }
    }
}

// MARK: - Filter Delegates
extension SearchFilterViewController: LevelPickerViewControllerDelegate,
                                      ClassFilterViewControllerDelegate,
                                      ComponentsFilterViewControllerDelegate {
    
    // Level
    func levelPicker(
        _ picker: LevelPickerViewController,
        didPickIndex index: Int,
        didPickLevel level: String)
    {
        levelFilters = index
        levelFilterValueLabel.text = level
    }
    
    // Class
    func classFilterPicker(
        _ picker: ClassFilterViewController,
        didPickIndexes indexes: Set<Int>,
        didPickClass dndClasses: [String])
    {
        classFilters = indexes
        classFilterValueLabel.text = dndClasses.joined(separator: ", ")
    }
    
    // Components
    func componentsFilterPicker(
        _ picker: ComponentsFilterViewController,
        didPickIndexes indexes: Set<Int>,
        didPickComponents components: [String])
    {
        componentsFilters = indexes
        componentsFilterValueLabel.text = components.joined(separator: ", ")
    }
    
    // School of Magic
    
    
    // Concentration
    
    
    // Reset all filters
}


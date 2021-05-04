//
//  SearchFilterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/29/21.
//

import UIKit
import CoreData

class SearchFilterViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var levelFilterValueLabel: UILabel!
    @IBOutlet weak var classFilterValueLabel: UILabel!
    @IBOutlet weak var componentsFilterValueLabel: UILabel!
    @IBOutlet weak var schoolFilterValueLabel: UILabel!
    @IBOutlet weak var concentrationFilterValueLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: - Instance Variables
    var levelFilters: Int = 0
    var classFilters: Set<Int> = []
    var componentsFilters: Set<Int> = []
    var schoolFilters: Int = 0
    var concentrationFilters: Int = 0
    
    var searchText: String?
    var levelText: String = "Any"
    var classText: String = "Any"
    var componentsText: String = "Any"
    var schoolText: String = "Any"
    var concentrationText: String = "Any"
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    var allSpellsViewController = AllSpellsViewController()
    
    // MARK: - Actions
    @IBAction func search(_ sender: Any) {
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let viewController = navController.viewControllers[navController.viewControllers.count - 2]
            if viewController is SearchResultsViewController {
                let tmp = viewController as! SearchResultsViewController
                tmp.searchBar.text = searchBar.text
                tmp.search.filters = createFilter()
                tmp.usedFilters = filtersToText()
                tmp.fetchSpells()
                tmp.performSearch(firstLoad: false, coreDataSpells: tmp.coreDataSpells)
                navigationController?.popViewController(animated: true)
            } else if viewController is AllSpellsViewController {
                performSegue(withIdentifier: "ShowSearchResultsFromFilter", sender: self)
            }
        }
    }
    
    @IBAction func searchButtonWasTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = CGAffineTransform.identity
                    
                    if let navController = self.navigationController, navController.viewControllers.count >= 2 {
                        let viewController = navController.viewControllers[navController.viewControllers.count - 2]
                        if viewController is SearchResultsViewController {
                            let tmp = viewController as! SearchResultsViewController
                            tmp.searchBar.text = self.searchBar.text
                            tmp.search.filters = self.createFilter()
                            tmp.usedFilters = self.filtersToText()
                            tmp.fetchSpells()
                            tmp.performSearch(firstLoad: false, coreDataSpells: tmp.coreDataSpells)
                            self.navigationController?.popViewController(animated: true)
                        } else if viewController is AllSpellsViewController {
                            self.performSegue(withIdentifier: "ShowSearchResultsFromFilter", sender: self)
                        }
                    }
            }
        })
    }
    
    @IBAction func resetAllFilters(_ sender: Any) {
        // Reset stored filtered indexes
        levelFilters = 0
        classFilters = [0]
        componentsFilters = [0]
        schoolFilters = 0
        concentrationFilters = 0
        
        // Reset labels for table view
        levelFilterValueLabel.text = "Any"
        classFilterValueLabel.text = "Any"
        componentsFilterValueLabel.text = "Any"
        schoolFilterValueLabel.text = "Any"
        concentrationFilterValueLabel.text = "Any"
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
        
        // Search text
        searchBar.text = searchText
        
        // Label text
        levelFilterValueLabel.text = levelText
        classFilterValueLabel.text = classText
        componentsFilterValueLabel.text = componentsText
        schoolFilterValueLabel.text = schoolText
        concentrationFilterValueLabel.text = concentrationText
    }
    
    // UI improvement - dismiss the keyboard when tapping out of a text field
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
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
                } else if viewController is SearchResultsViewController {
                    let tmp = viewController as! SearchResultsViewController
                    tmp.searchBar.text = searchBar.text
                }
            }
        }
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
            controller.selectedLevel = levelFilters
        }
        
        // Class
        if (segue.identifier == "ChooseClassFilter" && sender != nil) {
            let controller = segue.destination as! ClassFilterViewController
            controller.delegate = self
            controller.selectedClasses = classFilters
        }
        
        // Components
        if (segue.identifier == "ChooseComponentsFilter" && sender != nil) {
            let controller = segue.destination as! ComponentsFilterViewController
            controller.delegate = self
            controller.selectedComponents = componentsFilters
        }
        
        // School
        if (segue.identifier == "ChooseSchoolFilter" && sender != nil) {
            let controller = segue.destination as! SchoolFilterViewController
            controller.delegate = self
            controller.selectedSchool = schoolFilters
        }
        
        // Concentration
        if (segue.identifier == "ChooseConcentrationFilter" && sender != nil) {
            let controller = segue.destination as! ConcentrationFilterViewController
            controller.delegate = self
            controller.selectedConcentration = concentrationFilters
        }
        
        // Search results
        if (segue.identifier == "ShowSearchResultsFromFilter" && sender != nil) {
            let controller = segue.destination as! SearchResultsViewController
            controller.search.filters = createFilter()
            controller.usedFilters = filtersToText()
            controller.managedObjectContext = managedObjectContext
            controller.allSpellsViewController = allSpellsViewController
            if let searchText = searchBar.text {
                controller.searchedText = searchText
            }
        }
    }
}

// MARK: - Filter Delegates
extension SearchFilterViewController: LevelPickerViewControllerDelegate,
                                      ClassFilterViewControllerDelegate,
                                      ComponentsFilterViewControllerDelegate,
                                      SchoolFilterViewControllerDelegate,
                                      ConcentrationFilterViewControllerDelegate {
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
    func schoolPicker(
        _ picker: SchoolFilterViewController,
        didPickIndex index: Int,
        didPickSchool school: String)
    {
        schoolFilters = index
        schoolFilterValueLabel.text = school
    }
    
    // Concentration
    func concentrationPicker(
        _ picker: ConcentrationFilterViewController,
        didPickIndex index: Int,
        didPickConcentration concentration: String)
    {
        concentrationFilters = index
        concentrationFilterValueLabel.text = concentration
    }
    
    // Make a filter using current filter values
    func createFilter() -> Filter {
        let filter = Filter()
        
        // Level
        if (levelFilterValueLabel.text == "Any") {
            filter.levelFilter = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        } else {
            filter.levelFilter = [Double(levelFilterValueLabel.text!)!]
        }
        filter.levelIndex = levelFilters
        filter.levelString = levelFilterValueLabel.text!
        
        // Class
        if (classFilterValueLabel.text == "Any") {
            filter.classFilter = []
        } else {
            filter.classFilter = Set(classFilterValueLabel.text!.components(separatedBy: ", "))
        }
        filter.classIndexes = classFilters
        filter.classString = classFilterValueLabel.text!
        
        // Components
        if (componentsFilterValueLabel.text == "Any") {
            filter.componentsFilter = []
        } else {
            filter.componentsFilter = Set(componentsFilterValueLabel.text!.components(separatedBy: ", "))
        }
        filter.componentsIndexes = componentsFilters
        filter.componentsString = componentsFilterValueLabel.text!
        
        // School
        if (schoolFilterValueLabel.text == "Any") {
            filter.schoolFilter = ["Abjuration",
                                   "Conjuration",
                                   "Divination",
                                   "Enchantment",
                                   "Evocation",
                                   "Illusion",
                                   "Necromancy",
                                   "Transmutation"]
        } else {
            filter.schoolFilter = [schoolFilterValueLabel.text!]
        }
        filter.schoolIndex = schoolFilters
        filter.schoolString = schoolFilterValueLabel.text!
        
        // Concentration
        if (concentrationFilterValueLabel.text == "Any") {
            filter.concentrationFilter = ["yes", "no"]
        } else {
            filter.concentrationFilter = [concentrationFilterValueLabel.text!.lowercased()]
        }
        filter.concentrationIndex = concentrationFilters
        filter.concentrationString = concentrationFilterValueLabel.text!
        
        return filter
    }
    
    // Make a string using current filter values
    func filtersToText() -> String {
        var filterString = ""
        
        // Level
        filterString += "Level: " + levelFilterValueLabel.text! + ", "
        
        // Class
        filterString += "Classes: " + classFilterValueLabel.text! + ", "
        
        // Components
        filterString += "Components: " + componentsFilterValueLabel.text! + ", "
        
        // School
        filterString += "School: " + schoolFilterValueLabel.text! + ", "
        
        // Concentration
        filterString += "Concentration: " + concentrationFilterValueLabel.text!
        
        return filterString
    }
}

// MARK: - Search Bar Delegate
extension SearchFilterViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let viewController = navController.viewControllers[navController.viewControllers.count - 2]
            if viewController is SearchResultsViewController {
                let tmp = viewController as! SearchResultsViewController
                tmp.searchBar.text = self.searchBar.text
                tmp.search.filters = self.createFilter()
                tmp.usedFilters = self.filtersToText()
                tmp.fetchSpells()
                tmp.performSearch(firstLoad: false, coreDataSpells: tmp.coreDataSpells)
                self.navigationController?.popViewController(animated: true)
            } else if viewController is AllSpellsViewController {
                self.performSegue(withIdentifier: "ShowSearchResultsFromFilter", sender: self)
            }
        }
    }
}

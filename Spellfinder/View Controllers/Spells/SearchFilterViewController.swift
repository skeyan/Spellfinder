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
    

    
    // MARK: - Actions
    @IBAction func searchButtonWasTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = CGAffineTransform.identity
            }
        })
    }
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI
        searchButton.applyGradient(colors: [Helper.UIColorFromRGB(0x2CD0DD).cgColor, Helper.UIColorFromRGB(0xBB4BD2).cgColor])
        
        // Scroll table section headers like a regular cell
        let dummyViewHeight = CGFloat(50)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        
        // Remove 1px bottom border from search bar
        searchBar.backgroundImage = UIImage()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
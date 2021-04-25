//
//  AddCharacterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit

class AddCharacterViewController: UITableViewController {

    @IBOutlet weak var createCharacterButton: UIButton!
    @IBOutlet weak var classValueLabel: UILabel!
    @IBOutlet weak var nameValueTextField: UITextField!
    @IBOutlet weak var levelValueTextField: UITextField!
    @IBOutlet weak var iconTableViewCell: UITableViewCell!
    
    // MARK: - Actions
    @IBAction func createButtonWasTouched(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = CGAffineTransform.identity
                    // TO-DO: "Done" action - create character
                    self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    @IBAction func done() {
        navigationController?.popViewController(animated: true)
        // TO-DO: Create character for Core Data
    }

    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        createCharacterButton.applyGradient(colors: [Helper.UIColorFromRGB(0x2CD0DD).cgColor, Helper.UIColorFromRGB(0xBB4BD2).cgColor])
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.systemGray6.cgColor
        border.frame = CGRect(x: 0,
                              y: 0,
                              width: iconTableViewCell.frame.size.width,
                              height: 1
        )
        border.borderWidth = width
        iconTableViewCell.layer.addSublayer(border)
        iconTableViewCell.layer.masksToBounds = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Table View
    // UI improvement - Make custom layout for section headers
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white

        let sectionLabel = UILabel(frame: CGRect(x: 20, y: 28, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        sectionLabel.font = UIFont(name: "Retroica", size: 18)
        sectionLabel.textColor = UIColor.black
        sectionLabel.text = ""
        switch section {
        case 0:
            sectionLabel.text = "Name"
        case 1:
            sectionLabel.text = "Class"
        case 2:
            sectionLabel.text = "Level"
        default:
            sectionLabel.text = ""
        }
        
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)

        return headerView
    }
    
    // UI improvement - make the section headers taller
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // UI improvement - animate the deselection of rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // UI improvement - disable highlighting of rows
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1) {
            return true
        } else {
            return false
        }
    }
}

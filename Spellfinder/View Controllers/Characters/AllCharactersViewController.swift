//
//  AllCharactersViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit

class AllCharactersViewController: UIViewController {

    @IBOutlet weak var addCharacterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Instance Variables
    struct TableView {
      struct CellIdentifiers {
        static let characterCell = "CharacterCell"
      }
    }
    
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
    }
    
    // UI improvement - Add character button background helper function
    func imageFromColor(colour: UIColor) -> UIImage
    {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(colour.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
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

// MARK: - Table View Delegate
extension AllCharactersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.characterCell)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TO-DO: Perform segue to Character Detail
         
        // TO-DO: Perform segue to Add Character screen
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}

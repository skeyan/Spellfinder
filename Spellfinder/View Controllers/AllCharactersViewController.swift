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
    
    // MARK: - Actions
    @IBAction func addCharacterWasPressed(_ sender: UIButton) {
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

        // Do any additional setup after loading the view.
        // addCharacterButton.setBackgroundImage(imageFromColor(colour: UIColor.systemGray6), for: .highlighted)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TestCell")
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "TestCell")
        }
        cell?.backgroundColor = UIColor(named: "AccentColor")
        
        return cell!
    }
    
    
}

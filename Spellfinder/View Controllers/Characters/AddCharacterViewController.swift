//
//  AddCharacterViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/24/21.
//

import UIKit

class AddCharacterViewController: UITableViewController {
    
    
    
    // MARK: - Actions
      @IBAction func done() {
        navigationController?.popViewController(animated: true)
      }

      @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
      }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

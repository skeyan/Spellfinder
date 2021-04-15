//
//  DetailSpellViewController.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/14/21.
//

import UIKit

class DetailSpellViewController: UIViewController {
    
    @IBOutlet var spellNameLabel: UILabel!
    @IBOutlet var levelMagicClassLabel: UILabel!
    @IBOutlet var concentrationLabel: UILabel!
    @IBOutlet var ritualLabel: UILabel!
    
    @IBOutlet var castingTimeLabel: UILabel!
    @IBOutlet var castingTimeValueLabel: UILabel!
    @IBOutlet var rangeLabel: UILabel!
    @IBOutlet var rangeValueLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var durationValueLabel: UILabel!
    @IBOutlet var classesLabel: UILabel!
    @IBOutlet var classesValueLabel: UILabel!
    @IBOutlet var componentsLabel: UILabel!
    @IBOutlet var componentsValueLabel: UILabel!
    @IBOutlet var extraMaterialsLabel: UILabel!
    
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var higherLevelLabel: UILabel!
    @IBOutlet var higherLevelValueTextView: UITextView!
    
    // The search result that will be displayed
    var searchResultToDisplay: SearchResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let _ = searchResultToDisplay {
            configure(for: searchResultToDisplay!)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Helper Methods
    func configure(for searchResult: SearchResult) -> Void {
        spellNameLabel.text = searchResult.name
        levelMagicClassLabel.text = searchResult.level! + " " + searchResult.school!
        
        if searchResult.isConcentration {
            concentrationLabel.textColor = UIColor(named: "AccentColor")
        } else {
            concentrationLabel.textColor = UIColor(named: "GreyColor")
        }
        if searchResult.isRitual {
            ritualLabel.textColor = UIColor(named: "AccentColor")
        } else {
            ritualLabel.textColor = UIColor(named: "GreyColor")
        }
        
        castingTimeValueLabel.text = searchResult.castingTime
        rangeValueLabel.text = searchResult.range
        durationValueLabel.text = searchResult.duration
        classesValueLabel.text = searchResult.dndClass
        componentsValueLabel.text=searchResult.components
        
        // TO-DO: Configure the rest after fixing the UI in the storyboard
    }
}

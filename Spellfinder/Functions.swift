//
//  Functions.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/22/21.
//

import Foundation
import UIKit

// Global helper functions and variables
let applicationDocumentsDirectory: URL = {
  let paths = FileManager.default.urls(
    for: .documentDirectory,
    in: .userDomainMask)
  return paths[0]
}()

func spellsEntitiesToDict(_ arr: [Spell]) -> Dictionary<String, Spell> {
    var spellsDict = Dictionary<String, Spell>()
    for spell in arr {
        spellsDict[spell.slug!] = spell
    }
    return spellsDict
}

let dataSaveFailedNotification = Notification.Name(
  rawValue: "DataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
  print("*** Fatal error: \(error)")
  NotificationCenter.default.post(
    name: dataSaveFailedNotification,
    object: nil)
}

class Helper {
    static func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0,
                       green: ((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0,
                       blue: ((CGFloat)((rgbValue & 0x0000FF)))/255.0,
                       alpha: 1.0
        )
    }
    
    static func showNetworkAlert() -> Void {
        // Show alert on error
        let alertController = UIAlertController(title: "Network error", message: "The data could not be retrieved and parsed successfully from the API.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertController.show()
    }
}

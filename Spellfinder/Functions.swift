//
//  Functions.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/22/21.
//

import Foundation

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


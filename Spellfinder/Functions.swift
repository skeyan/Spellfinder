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



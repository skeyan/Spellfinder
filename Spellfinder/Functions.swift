//
//  Functions.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/22/21.
//

import Foundation

let applicationDocumentsDirectory: URL = {
  let paths = FileManager.default.urls(
    for: .documentDirectory,
    in: .userDomainMask)
  return paths[0]
}()



//
//  Bundle+Icon.swift
//  Spellfinder
//
//  Created by Eva Yan on 4/23/21.
//

import UIKit

extension Bundle {
  
  public var icon: UIImage? {
    
    if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
       let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
       let files = primary["CFBundleIconFiles"] as? [String],
       let icon = files.last
    {
      return UIImage(named: icon)
    }
    
    return nil
  }
}

//
//  CampusColor.swift
//  Rutgers
//
//  Created by Colin Walsh on 8/22/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation


enum CampusColor {
    case liv
    case collegeAve
    case cookDouglass
    case busch
    case newark
    case camden
    case downtown
}

extension CampusColor {
    var color: UIColor {
        switch self {
        case .liv:
            return UIColor(red:1.00, green:0.80, blue:0.60, alpha:1.0)
        case .collegeAve:
            return UIColor(red:0.80, green:1.00, blue:0.80, alpha:1.0)
        case .cookDouglass:
            return UIColor(red:1.00, green:1.00, blue:0.73, alpha:1.0)
        case .busch:
            return UIColor(red:0.75, green:0.93, blue:1.00, alpha:1.0)
        case .newark:
            return UIColor(red:0.93, green:0.93, blue:0.87, alpha:1.0)
        case .camden:
            return UIColor(red:0.89, green:0.75, blue:1.00, alpha:1.0)
        case .downtown:
            return UIColor(red:1.00, green:0.84, blue:0.94, alpha:1.0)
        }
    }
}

extension CampusColor {
    static func from(string: String) -> CampusColor {
        switch string {
        case "liv":
            return .liv
        case "cac":
            return .collegeAve
        case "d/c":
            return .cookDouglass
        case "bus":
            return .busch
        case "nwk":
            return .newark
        case "cam":
            return .camden
        case "dnb":
            return .downtown
        default:
            return .collegeAve
        }
    }
}

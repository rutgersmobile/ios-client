//
//  Array+RUAdditions.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/20/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation

extension Array {
    // Create a new array for elements where f is not nil
    func filterMap<T>(f: (Element) -> T?) -> [T] {
        return self.reduce([]) { (result, x) in
            if let y = f(x) {
                return result + [y]
            } else {
                return result
            }
        }
    }

    func any(_ f: (Element) -> Bool) -> Bool {
        for x in self {
            if (f(x)) {
                return true
            }
        }

        return false
    }

    func get(_ idx: Int) -> Element? {
        if idx >= 0 && idx < self.count {
            return self[idx]
        } else {
            return nil
        }
    }
}

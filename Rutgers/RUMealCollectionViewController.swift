//
//  RUMealCollectionViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 2/24/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation

class RUMealCollectionViewController: UIViewController {
    let meal: Meal

    init(meal: Meal) {
        self.meal = meal
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}

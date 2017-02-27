//
//  RUDiningHallViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 2/24/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation

class RUDiningHallTabBarController: UITabBarController, UITabBarControllerDelegate {
    var diningHall: DiningHall!

    static func instantiate(
        fromStoryboard storyboard: UIStoryboard,
        diningHall: DiningHall
    ) -> RUDiningHallTabBarController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUDiningHallTabBarController"
        ) as! RUDiningHallTabBarController

        me.diningHall = diningHall

        return me
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = diningHall.name

        self.viewControllers = diningHall.meals
            .filter { $0.isAvailable }
            .enumerated()
            .map { (i, meal) in
                let vc = RUMealViewController.instantiate(
                    withStoryboard: self.storyboard!,
                    meal: meal
                )
                vc.tabBarItem = UITabBarItem(
                    title: meal.name,
                    image: nil,
                    selectedImage: nil
                )
                return vc
            }
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        return true
    }
}

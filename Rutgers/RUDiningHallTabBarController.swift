//
//  RUDiningHallViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 2/24/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift

class RUDiningHallTabBarController
    : UITabBarController
    , UITabBarControllerDelegate
{
    static let nameShortToLong = [
        "brower": "Brower Commons",
        "busch": "Busch Dining Hall",
        "livi": "Livingston Dining Commons",
        "neilson": "Neilson Dining Hall"
    ]

    static let nameLongToShort = [
        "Brower Commons": "brower",
        "Busch Dining Hall": "busch",
        "Livingston Dining Commons": "livi",
        "Neilson Dining Hall": "neilson"
    ]

    var diningHall: DiningHallRepr!

    let myNameShortToLong = RUDiningHallTabBarController.nameShortToLong
    let myNameLongToShort = RUDiningHallTabBarController.nameLongToShort

    let disposeBag = DisposeBag()

    static func instantiate(
        fromStoryboard storyboard: UIStoryboard,
        diningHall: DiningHallRepr
    ) -> RUDiningHallTabBarController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUDiningHallTabBarController"
        ) as! RUDiningHallTabBarController

        me.diningHall = diningHall

        return me
    }

    override func sharingUrl() -> URL? {
        let name = { () -> String in switch (diningHall!) {
        case .fullDiningHall(let fullDiningHall):
            return fullDiningHall.name
        case .serializedDiningHall(let diningHallName):
            return diningHallName
        }}()

        return self.myNameLongToShort[name].flatMap { shortName in
            NSURL.rutgersUrl(withPathComponents: ["food", shortName])
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupShareButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch (diningHall!) {
        case .fullDiningHall(let fullDiningHall):
            setup(withFullDiningHall: fullDiningHall)
        case .serializedDiningHall(let diningHallName):
            RutgersAPI.sharedInstance.getDiningHalls()
                .observeOn(MainScheduler.instance)
                .flatMap { Observable.from($0) }
                .filter { $0.name == diningHallName }
                .subscribe(onNext: { fullDiningHall in
                    self.setup(withFullDiningHall: fullDiningHall)
                    self.tabBarController?.view.setNeedsDisplay()
                })
                .addDisposableTo(disposeBag)
        }
    }

    func setup(withFullDiningHall fullDiningHall: DiningHall) {
        self.title = fullDiningHall.name

        self.viewControllers = fullDiningHall.meals
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

enum DiningHallRepr {
    case fullDiningHall(DiningHall)
    case serializedDiningHall(String)
}

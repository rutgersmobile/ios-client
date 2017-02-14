//
//  RUFoodViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 2/13/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation

class RUFoodCollectionViewController: UICollectionViewController, RUChannelProtocol {
    var channel: [NSObject : AnyObject] = [:]
    let cellId = "FoodCellId"

    static func channelHandle() -> String! {
        return "food";
    }

    static func registerClass() {
        RUChannelManager.sharedInstance()
            .register(RUFoodCollectionViewController.self)
    }

    static func channel(
        withConfiguration channelConfiguration: [AnyHashable : Any]!
    ) -> Any! {
        let storyboard = UIStoryboard(name: "RUFoodStoryboard", bundle: nil)
        let me = storyboard.instantiateInitialViewController() as! RUFoodCollectionViewController
        me.channel = channelConfiguration as [NSObject : AnyObject]
        return me
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//
//  RUDiningHallStubViewController.swift
//  Rutgers
//
//  Created by Matt Robinson on 2/24/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation

class RUDiningHallStubViewController: UIViewController {
    var hallDescription: String!


    @IBOutlet weak var label: UILabel!


    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        hallDescription: String
    ) -> RUDiningHallStubViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUDiningHallStubViewController"
        ) as! RUDiningHallStubViewController

        me.hallDescription = hallDescription

        return me
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        label.text = hallDescription
    }
}

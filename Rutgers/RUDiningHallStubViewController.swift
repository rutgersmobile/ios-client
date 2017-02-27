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
        let label = UILabel(frame: CGRect(
            x: self.view.center.x,
            y: self.view.center.y,
            width: self.view.frame.height,
            height: self.view.frame.width
        ))

        label.numberOfLines = 50
        label.text = hallDescription

        self.view.addSubview(label)
    }
}

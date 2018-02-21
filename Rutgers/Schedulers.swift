//
//  Schedulers.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/29/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift

class Schedulers {
    static let instance = Schedulers()

    let background: ConcurrentDispatchQueueScheduler

    private init () {
        self.background = ConcurrentDispatchQueueScheduler(qos: .background)
    }
}

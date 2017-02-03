//
//  Motd.swift
//  Rutgers
//
//  Created by cfw37 on 2/1/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

struct Motd {
    let motd_description : String
    var title : String?
    var data : String?
    let isWindow : Bool
    let hasCloseButton : Bool
    let betaCheck : String
    
}

extension Motd: Unboxable {
    init(unboxer: Unboxer) throws {
        self.motd_description = try unboxer.unbox(key: "motd")
        self.title = try? unboxer.unbox(key: "title")
        self.data = try? unboxer.unbox(key: "data")
        self.isWindow = try unboxer.unbox(key: "isWindow")
        self.hasCloseButton = try unboxer.unbox(key: "hasCloseButton")
        self.betaCheck = try unboxer.unbox(key: "betaCheck")
    }
}





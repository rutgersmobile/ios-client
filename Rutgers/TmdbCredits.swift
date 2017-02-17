//
//  TmdbCredits.swift
//  Rutgers
//
//  Created by cfw37 on 2/13/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

struct TmdbCredits {
    let id : Int
    let cast : [Cast]
}

struct Cast {
    let castId : Int
    let character : String
    let creditId : String
    let id : Int
    let name : String
    let order : Int
    let profilePath : String?
}

extension TmdbCredits : Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.cast = try unboxer.unbox(key: "cast")
    }
}

extension Cast : Unboxable {
    init(unboxer: Unboxer) throws {
        self.castId = try unboxer.unbox(key: "cast_id")
        self.character = try unboxer.unbox(key: "character")
        self.creditId = try unboxer.unbox(key: "credit_id")
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.order = try unboxer.unbox(key: "order")
        self.profilePath = try? unboxer.unbox(key: "profile_path")
    }
    
}

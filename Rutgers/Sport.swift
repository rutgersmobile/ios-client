//
//  Sport.swift
//  Rutgers
//
//  Created by cfw37 on 1/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

struct Sport {
    let description : String
    let games : [Game]
}

struct Game {
    let gameDescription : String
    let home : Team
    let away : Team
    let location : String
    let isEvent : Bool
    let start: Start
}

struct Team {
    let name : String
    let code : String
    let score : Int?
}

struct Start {
    let date : String
    let time : Bool
    let timeString : String
}

extension Sport: Unboxable {
    init(unboxer: Unboxer) throws {
        self.games = try unboxer.unbox(key: "games")
        self.description = try unboxer.unbox(key: "description")
    }
}

extension Game: Unboxable {
    init(unboxer: Unboxer) throws {
        self.gameDescription = try unboxer.unbox(key: "description")
        self.home = try unboxer.unbox(key: "home")
        self.away = try unboxer.unbox(key: "away")
        self.location = try unboxer.unbox(key: "location")
        self.isEvent = try unboxer.unbox(key: "isEvent")
        self.start = try unboxer.unbox(key: "start")
    }
}

extension Team: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.code = try unboxer.unbox(key: "code")
        self.score = try? unboxer.unbox(key: "score")
    }
}

extension Start: Unboxable {
    init(unboxer: Unboxer) throws {
        self.date = try unboxer.unbox(key: "date")
        self.time = try unboxer.unbox(key: "time")
        self.timeString = try unboxer.unbox(key: "timeString")
    }
}

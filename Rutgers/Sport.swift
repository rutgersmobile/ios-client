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
    let games : [Games]
}

struct Games {
    let gameDescription : String
    let home : Home
    let away : Away
    let location : String
}

struct Home {
    let name : String
    let code : String
    let score : Int
}

struct Away {
    let name : String
    let code : String
    let score : String
}

struct Start {
    let date : String
    let time : String
    let timeString : String
}

extension Sport: Unboxable {
    init(unboxer: Unboxer) throws {
        self.games = try unboxer.unbox(key: "games")
    }
    
    
}

extension Games: Unboxable {
    init(unboxer: Unboxer) throws {
        self.gameDescription = try unboxer.unbox(key: "description")
        self.home = try unboxer.unbox(key: "home")
        self.away = try unboxer.unbox(key: "away")
        self.location = try unboxer.unbox(key: "location")
    }
}

extension Home: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.code = try unboxer.unbox(key: "code")
        
      
        self.score = try unboxer.unbox(key: "score")
        
//        else {
//            self.score = 0
//        }
        
            
        
    }
    
}

extension Away: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.code = try unboxer.unbox(key: "code")
        self.score = try unboxer.unbox(key: "score")
    }
    
}

extension Start: Unboxable {
    init(unboxer: Unboxer) throws {
        self.date = try unboxer.unbox(key: "date")
        self.time = try unboxer.unbox(key: "time")
        self.timeString = try unboxer.unbox(key: "timeString")
    }
    
}

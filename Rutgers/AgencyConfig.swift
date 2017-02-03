//
//  AgencyConfig.swift
//  Rutgers
//
//  Created by cfw37 on 2/3/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

struct AgencyConfig {
    let route : [String : Route]
    let stop : [String : Stop]
    let stopsByTitle : [String : StopsByTitle]
    let sortedStops : [SortedStops]
}

struct Route {
    let stops : [String]
    let title: String
    let directions : [Directions]
}

struct Directions {
    let title : String
    let tag : String
}

struct Stop {
    let routes : [String]
    let title : String
    let lat : Double
    let long : Double
    //let stopId : String //Cannot find key?  Copy/pasted from API - still does not work
}

struct StopsByTitle {
    let tags: [String]
    let geoHash: String
}

struct SortedStops {
    let title: String
    let geoHash: String
}

extension AgencyConfig: Unboxable {
    init(unboxer: Unboxer) throws {
        self.route = try unboxer.unbox(keyPath: "routes")
        self.stop = try unboxer.unbox(keyPath: "stops")
        self.stopsByTitle = try unboxer.unbox(keyPath: "stopsByTitle")
        self.sortedStops = try unboxer.unbox(keyPath: "sortedStops")
    }
}

extension Route: Unboxable {
    init(unboxer: Unboxer) throws {
        self.stops = try unboxer.unbox(keyPath: "stops")
        self.directions = try unboxer.unbox(keyPath: "directions")
        self.title = try unboxer.unbox(keyPath: "title")
    }
}

extension Directions: Unboxable {
    init(unboxer: Unboxer) throws {
        self.title = try unboxer.unbox(keyPath: "title")
        self.tag = try unboxer.unbox(keyPath: "tag")
    }
}

extension Stop: Unboxable {
    init(unboxer: Unboxer) throws {
        self.routes = try unboxer.unbox(keyPath: "routes")
        self.title = try unboxer.unbox(keyPath: "title")
        self.lat = try unboxer.unbox(keyPath: "lat")
        self.long = try unboxer.unbox(keyPath: "lon")
        //self.stopId = try unboxer.unbox(keyPath: "stopId")
    }
}

extension StopsByTitle: Unboxable {
    init(unboxer: Unboxer) throws {
        self.tags = try unboxer.unbox(keyPath: "tags")
        self.geoHash = try unboxer.unbox(keyPath: "geoHash")
    }
}

extension SortedStops: Unboxable {
    init(unboxer: Unboxer) throws {
        self.title = try unboxer.unbox(keyPath: "title")
        self.geoHash = try unboxer.unbox(keyPath: "geoHash")
    }
}

//
//  Cinema.swift
//  Rutgers
//
//  Created by cfw37 on 2/3/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

struct Cinema {
    let movieId : Int
    let tmdbId : Int
    let name : String
    let rating : String
    let runtime : Int
    let studio : String
    let showings: [Showings]
}

struct Showings {
    let sessionId: Int
    let movieId: Int
    let dateTime: String
    let audId: Int
}

extension Cinema: Unboxable {
    init(unboxer: Unboxer) throws {
        self.movieId = try unboxer.unbox(keyPath: "movie_id")
        self.tmdbId = try unboxer.unbox(keyPath: "tmdb_id")
        self.name = try unboxer.unbox(keyPath: "name")
        self.rating = try unboxer.unbox(keyPath: "rating")
        self.runtime = try unboxer.unbox(keyPath: "runtime")
        self.studio = try unboxer.unbox(keyPath: "studio")
        self.showings = try unboxer.unbox(keyPath: "showings")
    }
}

extension Showings: Unboxable {
    init(unboxer: Unboxer) throws {
        self.sessionId = try unboxer.unbox(keyPath: "session_id")
        self.movieId = try unboxer.unbox(keyPath: "movie_id")
        self.dateTime = try unboxer.unbox(keyPath: "dateTime")
        self.audId = try unboxer.unbox(keyPath: "aud_id")
    }
}

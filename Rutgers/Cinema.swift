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

    func formattedShowings() -> [String] {
        if (self.showings.isEmpty) {
            return []
        }

        //Used for date formatting
        let calendar = Calendar.current

        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = .short

        let sortedArray = self.showings.sorted {
            $0.dateTime < $1.dateTime
        }

        let baseDay = calendar.component(
            .day, from: sortedArray[0].dateTime as Date
        )

        let showingArray = sortedArray.filter {
            calendar.component(
                .day, from: $0.dateTime as Date
            ) == baseDay
        }

        return showingArray.map {
            dateFormatter.string(from: $0.dateTime)
        }
    }
}

struct Showings {
    let sessionId: Int
    let movieId: Int
    let dateTime: Date
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
        let dateString : String = try unboxer.unbox(keyPath: "dateTime")
        
        if let dateTime = showingDateFormatter.dateFormatter.date(from: dateString) {
            self.dateTime = dateTime
        } else {
            self.dateTime = Date()
        }
        self.audId = try unboxer.unbox(keyPath: "aud_id")
    }
    
    
}

struct showingDateFormatter {
    static let dateFormatter = newDateFormatter()
    
    static func newDateFormatter () -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        
        return dateFormatter
    }
}

//
//  TmdbData.swift
//  Rutgers
//
//  Created by cfw37 on 2/8/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

struct TmdbData {
    let adult : Bool?
    let backdropPath : String?
    let budget : Int?
    let genres : [Genres]?
    let homePage : String?
    let id : Int?
    let imdbId : String?
    let overview : String?
    let popularity : Double?
    let posterPath : String?
    let productionCompanies : [ProductionCompanies]?
    let productionCountries : [ProductionCountries]?
    let releaseDate : String?
    let revenue : Int?
    let runtime : Int?
    let status : String?
    let tagline : String?
    let title : String?
    let voteAverage : Double?
    let voteCount : Int?
    let videos : Videos?
    
    
}

struct Videos {
    let videoResult : [VideoResults]
}

struct VideoResults {
    let id : String
    let key : String
    let name : String
}

struct Genres {
    let id : Int
    let name : String
}

struct ProductionCompanies {
    let name : String
    let id : Int
}

struct ProductionCountries {
    let iso : String
    let name : String
}

extension TmdbData: Unboxable {
    init(unboxer: Unboxer) throws {
        self.adult = try? unboxer.unbox(key: "adult")
        self.backdropPath = try? unboxer.unbox(key: "backdrop_path")
        self.budget = try? unboxer.unbox(key: "budget")
        self.genres = try? unboxer.unbox(key: "genres")
        self.homePage = try? unboxer.unbox(key: "homepage")
        self.id = try? unboxer.unbox(key: "id")
        self.imdbId = try? unboxer.unbox(key: "imdb_id")
        self.overview = try? unboxer.unbox(key: "overview")
        self.popularity = try? unboxer.unbox(key: "popularity")
        self.posterPath = try? unboxer.unbox(key: "poster_path")
        self.productionCompanies = try? unboxer.unbox(key: "production_companies")
        self.productionCountries = try? unboxer.unbox(key: "production_countries")
        self.releaseDate = try? unboxer.unbox(key: "release_date")
        self.revenue = try? unboxer.unbox(key: "revenue")
        self.runtime = try? unboxer.unbox(key: "runtime")
        self.status = try? unboxer.unbox(key: "status")
        self.tagline = try? unboxer.unbox(key: "tagline")
        self.title = try? unboxer.unbox(key: "title")
        self.voteAverage = try? unboxer.unbox(key: "vote_average")
        self.voteCount = try? unboxer.unbox(key: "vote_count")
        self.videos = try? unboxer.unbox(key: "videos")
    }
    
    
}

extension Videos: Unboxable {
    init(unboxer: Unboxer) throws {
        self.videoResult = try unboxer.unbox(key: "results")

    }
}

extension VideoResults: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.key = try unboxer.unbox(key: "key")
        self.name = try unboxer.unbox(key: "name")
    }
}

extension Genres: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.id = try unboxer.unbox(key: "id")
    }
    
}

extension ProductionCompanies: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.id = try unboxer.unbox(key: "id")
    }
}

extension ProductionCountries: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.iso = try unboxer.unbox(key: "id")
    }
    
}

//
//  food.swift
//  Rutgers
//
//  Created by Matt Robinson on 1/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

struct DiningHall {
    let name: String
    let date: Int
    let meals: [Meal]
}

struct Meal {
    let name: String
    let isAvailable: Bool
    let genres: [Genre]
}

struct Genre {
    let name: String
    let items: [String]
}

extension DiningHall: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "location_name")
        self.date = try unboxer.unbox(key: "date")
        self.meals = try unboxer.unbox(key: "meals")
    }
}

extension Meal: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "meal_name")
        self.isAvailable = try unboxer.unbox(key: "meal_avail")
        do {
            self.genres = try unboxer.unbox(key: "genres")
        } catch {
            self.genres = []
        }
    }
}

extension Genre: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "genre_name")
        self.items = try unboxer.unbox(key: "items")
    }
}

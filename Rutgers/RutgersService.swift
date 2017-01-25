//
//  RutgersService.swift
//  Rutgers
//
//  Created by Matt Robinson on 1/25/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Moya

enum RutgersService {
    case getDiningHalls
    case getGames(sport: String)
}

extension RutgersService : TargetType {
    var baseURL: URL {
        return URL(string: "https://doxa.rutgers.edu")!
    }
}

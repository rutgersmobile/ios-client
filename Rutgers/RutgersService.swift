//
//  RutgersService.swift
//  Rutgers
//
//  Created by Matt Robinson on 1/25/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum RutgersService {
    case getDiningHalls
    case getGames(sport: String)
}

extension RutgersService : TargetType {
    var baseURL: URL {
//        return URL(string: "https://doxa.rutgers.edu/mobile-mattro/3")!
        return URL(string: "https://doxa.rutgers.edu/mobile/2")!
    }

    var path: String {
        switch self {
        case .getDiningHalls:
            return "/rutgers-dining.txt"
        case .getGames(let sport):
            return "/sports/\(sport).json"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var parameters: [String: Any]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    var sampleData: Data {
        return "test".data(using: .utf8)!
    }

    var task: Task {
        switch self {
        case .getDiningHalls, .getGames:
            return .request
        }
    }
}

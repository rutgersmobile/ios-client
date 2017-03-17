//
//  SOCService.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/16/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Moya

enum SOCService {
    case getCourses(semester: Semester, campus: Campus)
    case getInit
}

extension SOCService: TargetType {
    var baseURL: URL {
        return URL(string: "https://test-sis.rutgers.edu/soc/")!
    }

    var path: String {
        switch self {
        case .getCourses(_, _):
            return "courses.gz"
        case .getInit:
            return "init.json"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var parameters: [String: Any]? {
        switch self {
        case .getCourses(let semester, let campus):
            return [
                "year": semester.year,
                "term": semester.term,
                "campus": campus
            ]
        case .getInit:
            return nil
        }
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    var sampleData: Data {
        return "test".data(using: .utf8)!
    }

    var task: Task {
        return .request
    }
}

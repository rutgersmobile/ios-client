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
    case getMotd
    case getChannel
    case getNBAgency
    case getCinema
    case getSOCInit
    case getBuilding(buildingCode: String)
    case getSubjects(options: SOCOptions)
    case getCourse(options: SOCOptions, subjectCode: Int, courseNumber: Int)
    case getCourses(options: SOCOptions, subjectCode: Int)
    case getSections(options: SOCOptions, subjectNumber: Int, courseNumber: Int)
    case getSearch(options: SOCOptions, query: String)
}

extension RutgersService : TargetType {
    var baseURL: URL {
        return RUNetworkManager.baseURL()
    }

    var path: String {
        switch self {
        case .getDiningHalls:
            return "/food.json"
        case .getGames(let sport):
            return "/sports/\(sport).json"
        case .getMotd:
            return "/motd.txt"
        case .getChannel:
            return "/ordered_content.json"
        case .getNBAgency:
            return "/rutgersrouteconfig.txt"
        case .getCinema:
            return "/rutgers-cinema.txt"
        case .getSOCInit:
            return "/init.json"
        case .getSubjects:
            return "/subjects.json"
        case .getCourse:
            return "/course.json"
        case .getCourses:
            return "/courses.json"
        case .getSections:
            return "/sections.json"
        case .getSearch:
            return "/search.json"
        case .getBuilding:
            return "/building.json"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var parameters: [String: Any]? {
        switch self {
        case .getBuilding(let code):
            return ["code" : code]
        case .getSubjects(let options):
            return [
                "term" : options.semester.term,
                "year" : options.semester.year,
                "level" : options.level.description,
                "campus" : options.campus.description
                ]
        case .getCourse(let options, let subjectCode, let courseNumber):
            return [
                "term" : options.semester.term,
                "year" : options.semester.year,
                "level" : options.level.description,
                "campus" : options.campus.description,
                "subject": subjectCode,
                "course" : courseNumber
            ]
        case .getCourses(let options, let subjectCode):
            return [
                "term" : options.semester.term,
                "year" : options.semester.year,
                "level" : options.level.description,
                "campus" : options.campus.description,
                "subject" : subjectCode
            ]
        case .getSections(let options, let subjectNumber, let courseNumber):
            return [
                "term" : options.semester.term,
                "year" : options.semester.year,
                "level" : options.level.description,
                "campus" : options.campus.description,
                "subject" : subjectNumber,
                "course" : courseNumber
            ]
        case .getSearch(let options, let query):
            return [
                "term" : options.semester.term,
                "year" : options.semester.year,
                "level" : options.level.description,
                "campus" : options.campus.description,
                "q" : query
            ]
        default:
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
        switch self {
        case .getDiningHalls, .getGames, .getMotd, .getChannel, .getNBAgency, .getCinema, .getSOCInit, .getSubjects, .getCourse, .getCourses, .getSections, .getSearch, .getBuilding:
            return .request
        }
    }
}

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
    case getSubjects(semester: Semester, campus: Campus, level: Level)
    case getCourse(semester: Semester, campus: Campus, level: Level, subject: Int, course: Int)
    case getCourses(semester: Semester, campus: Campus, level: Level, subject: Subject)
    case getSections(semester: Semester, campus: Campus, level: Level, course: Course)
    case getSection(semester: Semester, campus: Campus, level: Level, subjectNumber: Int, courseNumber: Int, sectionNumber: Int)
    case getSearch(semester: Semester, campus: Campus, level: Level, query: String)
}

extension RutgersService : TargetType {
    var baseURL: URL {
        return RUNetworkManager.baseURL()
      //return URL(string: "https://doxa.rutgers.edu/mobile-mattro/3")!
      //return URL(string: "https://doxa.rutgers.edu/mobile/3")!
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
        case .getSection:
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
        case .getSubjects(let semester, let campus, let level):
            return [
                "term" : semester.term,
                "year" : semester.year,
                "level" : level.description,
                "campus" : campus.description
                ]
        case .getCourse(let semester, let campus, let level, let subject, let course):
            return [
                "term" : semester.term,
                "year" : semester.year,
                "level" : level.description,
                "campus" : campus.description,
                "subject": subject,
                "course" : course
            ]
        case .getCourses(let semester, let campus, let level, let subject):
            return [
                "term" : semester.term,
                "year" : semester.year,
                "level" : level.description,
                "campus" : campus.description,
                "subject" : subject.code
            ]
        case .getSections(let semester, let campus, let level, let course):
            return [
                "term" : semester.term,
                "year" : semester.year,
                "level" : level.description,
                "campus" : campus.description,
                "subject" : course.subject,
                "course" : course.courseNumber
            ]
        case .getSection(let semester, let campus, let level, let subjectNumber, let courseNumber, let sectionNumber):
            return [
                "term" : semester.term,
                "year" : semester.year,
                "level" : level.description,
                "campus" : campus.description,
                "subject" : subjectNumber,
                "course" : courseNumber,
                "section" : sectionNumber
            ]
        case .getSearch(let semester, let campus, let level, let query):
            return [
                "term" : semester.term,
                "year" : semester.year,
                "level" : level.description,
                "campus" : campus.description,
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
        case .getDiningHalls, .getGames, .getMotd, .getChannel, .getNBAgency, .getCinema, .getSOCInit, .getSubjects, .getCourse, .getCourses, .getSections, .getSearch, .getBuilding, .getSection:
            return .request
        }
    }
}

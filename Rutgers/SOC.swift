//
//  SOC.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/16/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Unbox

enum Campus {
    case newBrunswick
    case onlineNewBrunswick
    case newark
    case onlineNewark
    case camden
    case onlineCamden
}

extension Campus: CustomStringConvertible {
    var description: String {
        switch self {
        case .newBrunswick:
            return "NB"
        case .onlineNewBrunswick:
            return "ONLINE_NB"
        case .newark:
            return "NK"
        case .onlineNewark:
            return "ONLINE_NK"
        case .camden:
            return  "CM"
        case .onlineCamden:
            return "ONLINE_CM"
        }
    }
}

extension Campus {
    static func from(string s: String) -> Campus? {
        switch s {
        case "NB":
            return .newBrunswick
        case "ONLINE_NB":
            return .onlineNewBrunswick
        case "NK":
            return .newark
        case "ONLINE_NK":
            return .onlineNewark
        case "CM":
            return .camden
        case "ONLINE_CM":
            return .onlineCamden
        default:
            return nil
        }
    }

    var title: String {
        get {
            switch self {
            case .newBrunswick:
                return "New Brunswick"
            case .onlineNewBrunswick:
                return "Online New Brunswick"
            case .newark:
                return "Newark"
            case .onlineNewark:
                return "Online Newark"
            case .camden:
                return "Camden"
            case .onlineCamden:
                return "Online Camden"
            }
        }
    }

    static let allValues: [Campus] = [
        .newBrunswick,
        .onlineNewBrunswick,
        .newark,
        .onlineNewark,
        .camden,
        .onlineCamden
    ]
}

enum Level {
    case u
    case g
}

extension Level: CustomStringConvertible {
    var description: String {
        switch self {
        case .u:
            return "U"
        case .g:
            return "G"
        }
    }
}

extension Level {
    static func from(string s: String) -> Level? {
        switch s {
        case "U":
            return .u
        case "G":
            return .g
        default:
            return nil
        }
    }

    var title: String {
        get {
            switch self {
            case .u:
                return "Undergraduate"
            case .g:
                return "Graduate"
            }
        }
    }

    static let allValues: [Level] = [.u, .g]
}

struct Semester {
    let year: Int
    let term: Int
}


extension Semester {
    func toDict() -> [String: Any] {
        return [
            "year": self.year,
            "term": self.term
        ]
    }
    
    /*
    var previous: Semester {
        switch self.term {
        case .winter:
            return Semester(year: self.year - 1, term: 9)
        case .spring:
            return Semester(year: self.year, term: 0)
        case .summer:
            return Semester(year: self.year, term: 1)
        case .fall:
            return Semester(year: self.year, term: 7)
        }
    }

    func previousSemesters(number: Int) -> [Semester] {
        var semester = self
        var semesters: [Semester] = []
        for _ in 0..<number {
            semesters.append(semester)
            semester = semester.previous
        }
        return semesters
    }*/

    static func fromDict(dict: [String: Any]) -> Semester? {
        return (dict["year"] as? Int).flatMap { year in
            (dict["term"] as? Int).flatMap { intTerm in
                Term(intTerm).map { term in
                    Semester(year: year, term: term.asInt())
                }
            }
        }
    }
 
}

extension Semester: CustomStringConvertible {
    var description: String {
        return "\(self.term) \(self.year)"
    }
}


enum Term {
    case winter
    case spring
    case summer
    case fall
}

extension Term {
    init?(_ term: Int) {
        switch term {
        case 0:
            self = .winter
        case 1:
            self = .spring
        case 7:
            self = .summer
        case 9:
            self = .fall
        default:
            return nil
        }
    }

    func asInt() -> Int {
        switch self {
        case .winter:
            return 0
        case .spring:
            return 1
        case .summer:
            return 7
        case .fall:
            return 9
        }
    }
}
 

struct Course {
    let title: String
    let subject: String
    let courseNumber: String
    let courseDescription: String?
    let preReqNotes: String?
    let synopsisUrl: String?
    let credits: Float?
    let sectionCheck: SectionCheck
    let level: Level
}

struct SectionCheck {
    let open: Int
    let total: Int
}

struct Section {
    let subtopic: String?
    let subtitle: String?
    let index: String
    let number: String
    let examCode: String
    let printed: String
    let openStatus: Bool
    let sectionNotes: String?
    let sessionDates: String?
    let sessionDatePrintIndicator: String?
    let campusCode: String
    let instructors: [Instructor]
    let meetingTimes: [MeetingTime]
}

struct Instructor {
    let name: String
}

struct MeetingTime {
    let meetingDay: String?
    let meetingModeDesc: String?
    let startTime: String?
    let endTime: String?
    let pmCode: String?
    let campusAbbrev: String?
    let buildingCode: String?
    let roomNumber: String?
}

struct Init {
    let semesters: [Semester]
    let campus: [String]
}

struct TermDate {
    let date: String
    let year: Int
    let campus: String
    let term: Int
}

struct Subject {
    let subjectDescription: String
    let code: Int
}

enum SOCParseError: Error {
    case invalidValueFormat(message: String)
}

extension Semester: Unboxable {
    init(unboxer: Unboxer) throws {
        self.term = try unboxer.unbox(key: "term")
        self.year = try unboxer.unbox(key: "year")
    }
}
extension SectionCheck: Unboxable {
    init(unboxer: Unboxer) throws {
        self.open = try unboxer.unbox(key: "open")
        self.total = try unboxer.unbox(key: "total")
    }
}
extension Course: Unboxable {
    init(unboxer: Unboxer) throws {
        self.title = try unboxer.unbox(key: "title")
        self.subject = try unboxer.unbox(key: "subject")
        self.courseNumber = try unboxer.unbox(key: "number")
        self.courseDescription = try? unboxer.unbox(key: "courseDescription")
        self.preReqNotes = try? unboxer.unbox(key: "preReqNotes")
        self.synopsisUrl = try? unboxer.unbox(key: "synopsisUrl")
        self.sectionCheck = try unboxer.unbox(keyPath: "sections")
        self.credits = try? unboxer.unbox(key: "credits")
                let levelString = try unboxer.unbox(key: "level") as String
        guard let level = Level.from(string: levelString) else {
            throw SOCParseError.invalidValueFormat(
                message: "Couldn't parse level: \(levelString)"
            )
        }
        self.level = level
    }
}

extension Section: Unboxable {
    init(unboxer: Unboxer) throws {
        self.subtopic = try? unboxer.unbox(key: "subtopic")
        self.subtitle = try? unboxer.unbox(key: "subtitle")
        self.index = try unboxer.unbox(key: "index")
        self.number = try unboxer.unbox(key: "number")
        self.examCode = try unboxer.unbox(key: "examCode")
        self.printed = try unboxer.unbox(key: "printed")
        self.openStatus = try unboxer.unbox(key: "openStatus")
        self.sectionNotes = try? unboxer.unbox(key: "sectionNotes")
        self.sessionDates = try? unboxer.unbox(key: "sessionDates")
        self.sessionDatePrintIndicator =
            try? unboxer.unbox(key: "sessionDatePrintIndicator")
        self.campusCode = try unboxer.unbox(key: "campusCode")
        self.instructors = try unboxer.unbox(key: "instructors")
        self.meetingTimes = try unboxer.unbox(key: "meetingTimes")
    }
}

extension Instructor: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
    }
}

extension MeetingTime: Unboxable {
    init(unboxer: Unboxer) throws {
        self.meetingDay = try? unboxer.unbox(key: "meetingDay")
        self.meetingModeDesc = try? unboxer.unbox(key: "meetingModeDesc")
        self.startTime = try? unboxer.unbox(key: "startTime")
        self.endTime = try? unboxer.unbox(key: "endTime")
        self.pmCode = try? unboxer.unbox(key: "pmCode")
        self.campusAbbrev = try? unboxer.unbox(key: "campusAbbrev")
        self.buildingCode = try? unboxer.unbox(key: "buildingCode")
        self.roomNumber = try? unboxer.unbox(key: "roomNumber")
    }
}

extension Init: Unboxable {
    init(unboxer: Unboxer) throws {
        self.semesters = try unboxer.unbox(keyPath: "semesters")
        self.campus = try unboxer.unbox(key: "campuses")
    }
}

extension TermDate: Unboxable {
    init(unboxer: Unboxer) throws {
        self.date = try unboxer.unbox(key: "date")
        self.year = try unboxer.unbox(key: "year")
        self.campus = try unboxer.unbox(key: "campus")
        self.term = try unboxer.unbox(key: "term")
    }
}

extension Subject: Unboxable {
    init(unboxer: Unboxer) throws {
        self.subjectDescription = try unboxer.unbox(key: "subjectDescription")
        self.code = try unboxer.unbox(key: "subject")
    }
}

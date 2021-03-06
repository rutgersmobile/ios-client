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

struct Building {
    let code: String
    let campus: String
    let name: String
    let id: String
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
        case 7:
            return Semester(year: self.year - 1, term: 9)
        case .spring:
            return Semester(year: self.year, term: 0)
        case .summer:
            return Semester(year: self.year, term: 1)
        case .fall:
            return Semester(year: self.year, term: 7)
        }
    }*/
    
    var title: String {
        switch self.term {
        case 9:
            return "Fall"
        case 7:
            return "Summer"
        case 1:
            return "Spring"
        default:
            return "Winter"
        }
        
    }
    
    /*
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
        return "\(self.title) \(self.year)"
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
    let title: String?
    let subject: Int?
    let expandedTitle: String?
    let notes: String?
    let subjectNotes: String?
    let string: String?
    let courseNumber: Int?
    let courseDescription: String?
    let preReqNotes: String?
    let synopsisUrl: String?
    let unitNotes: String?
    let credits: Float?
    let creditsObject : CreditsObject
    let sectionCheck: SectionCheck
    let level: Level
    let coreCodes: [CoreCode]
    let supplementCode: String
}

struct CoreCode {
    let code: String
    let coreCode: String
    let coreCodeDescription: String
    let coreCodeReferenceId: String
    let course: Int
    let description: String
    let effective: String
    let id: String
    let lastUpdated: Int
    let offeringUnitCampus: String
    let offeringUnitCode: String
    let subject: Int
    let supplement: String
    let term: Int
    let unit: String
    let year: String
}

struct CreditsObject {
    let code: String
    let description : String
}

struct SectionCheck {
    let open: Int
    let total: Int
}

struct Section {
    let subtopic: String?
    let subtitle: String?
    let sectionIndex: String
    let sectionEligibility: String?
    let number: String
    let examCode: String
    let printed: String
    let openStatus: Bool
    let sectionNotes: String?
    let sessionDates: String?
    let sessionDatePrintIndicator: String?
    let commentsText: String?
    let campusCode: String
    let openToText: String?
    let specialPermission: String?
    let instructors: [Instructor]
    var meetingTimes: [MeetingTime]
}

struct Instructor {
    let instructorName: String
    let sectionId: Int
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

extension MeetingTime {

    func asInt() -> Int {
        if let meetingDay = self.meetingDay {
            switch meetingDay {
            case "M":
                return 0
            case "T":
                return 1
            case "W":
                return 2
            case "TH":
                return 3
            case "F":
                return 4
            default:
                return 5
            }
        } else {
            return 0
        }
    }
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

struct SearchResults {
    let subjects: [Subject]
    let courses: [Course]
}

enum SOCParseError: Error {
    case invalidValueFormat(message: String)
}

extension Building: Unboxable {
    init(unboxer: Unboxer) throws {
        self.code = try unboxer.unbox(key: "code")
        self.campus = try unboxer.unbox(key: "campus")
        self.name = try unboxer.unbox(key: "name")
        self.id = try unboxer.unbox(key: "id")
    }
}

extension SearchResults: Unboxable {
    init(unboxer: Unboxer) throws {
        self.subjects = try unboxer.unbox(key: "subjects")
        self.courses = try unboxer.unbox(key: "courses")
    }
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
        self.title = try? unboxer.unbox(key: "title")
        self.subject = try? unboxer.unbox(key: "subject")
        self.expandedTitle = try? unboxer.unbox(key: "expandedTitle")
        self.notes = try? unboxer.unbox(key: "notes")
        self.subjectNotes = try? unboxer.unbox(key: "subjectNotes")
        self.string = try? unboxer.unbox(key: "string")
        self.courseNumber = try? unboxer.unbox(key: "number")
        self.courseDescription = try? unboxer.unbox(key: "courseDescription")
        self.unitNotes = try? unboxer.unbox(key: "unitNotes")
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
        self.creditsObject = try unboxer.unbox(key: "creditsObject")
        self.level = level
        self.coreCodes = try unboxer.unbox(key: "coreCodes")
        self.supplementCode = try unboxer.unbox(key: "supplementCode")
    }
}

extension CreditsObject: Unboxable {
    init(unboxer: Unboxer) throws {
        self.code = try unboxer.unbox(key: "code")
        self.description = try unboxer.unbox(key: "description")
    }
}

extension CoreCode: Unboxable {
    init(unboxer: Unboxer) throws {
        self.code = try unboxer.unbox(key: "code")
        self.coreCode = try unboxer.unbox(key: "coreCode")
        self.coreCodeDescription = try unboxer.unbox(key: "coreCodeDescription")
        self.coreCodeReferenceId = try unboxer.unbox(key: "coreCodeReferenceId")
        self.course = try unboxer.unbox(key: "course")
        self.description = try unboxer.unbox(key: "description")
        self.effective = try unboxer.unbox(key: "effective")
        self.id = try unboxer.unbox(key: "id")
        self.lastUpdated = try unboxer.unbox(key: "lastUpdated")
        self.offeringUnitCampus = try unboxer.unbox(key: "offeringUnitCampus")
        self.offeringUnitCode = try unboxer.unbox(key: "offeringUnitCode")
        self.subject = try unboxer.unbox(key: "subject")
        self.supplement = try unboxer.unbox(key: "supplement")
        self.term = try unboxer.unbox(key: "term")
        self.unit = try unboxer.unbox(key: "unit")
        self.year = try unboxer.unbox(key: "year")
    }
}

extension Section: Unboxable {
    init(unboxer: Unboxer) throws {
        self.subtopic = try? unboxer.unbox(key: "subtopic")
        self.subtitle = try? unboxer.unbox(key: "subtitle")
        self.sectionIndex = try unboxer.unbox(key: "sectionIndex")
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
        self.commentsText = try? unboxer.unbox(key: "commentsText")
        self.sectionEligibility = try? unboxer.unbox(key: "sectionEligibility")
        self.openToText = try? unboxer.unbox(key: "openToText")
        self.specialPermission = try? unboxer.unbox(key: "specialPermissionAddCodeDescription")
    }
}

extension Instructor: Unboxable {
    init(unboxer: Unboxer) throws {
        self.instructorName = try unboxer.unbox(key: "instructorName")
        self.sectionId = try unboxer.unbox(key: "sectionId")
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

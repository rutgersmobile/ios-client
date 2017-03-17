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
    static func fromString(s: String) -> Campus? {
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
}

struct Semester {
    let year: Int
    let term: Int
}

struct Course {
    let title: String
    let subject: String
    let courseNumber: String
    let courseDescription: String
    let preReqNotes: String
    let synopsisUrl: String
    let credits: Float
    let sections: [Section]
    let level: String
}

struct Section {
    let subtopic: String
    let subtitle: String
    let index: String
    let number: String
    let examCode: String
    let printed: String
    let openStatus: Bool
    let sectionNotes: String
    let sessionDates: String
    let sessionDatePrintIndicator: String
    let campusCode: String
    let instructors: [Instructor]
    let meetingTimes: [MeetingTime]
}

struct Instructor {
    let name: String
}

struct MeetingTime {
    let meetingDay: String
    let meetingModeDesc: String
    let startTime: String
    let endTime: String
    let pmCode: String
    let campusAbbrev: String
    let buildingCode: String
    let roomNumber: String
}

struct Init {
    let currentTermDate: TermDate
    let subjects: [Subject]
}

struct TermDate {
    let date: String
    let year: String
    let campus: String
    let term: String
}

struct Subject {
    let description: String
    let code: String
}

extension Course: Unboxable {
    init(unboxer: Unboxer) throws {
        self.title = try unboxer.unbox(key: "title")
        self.subject = try unboxer.unbox(key: "subject")
        self.courseNumber = try unboxer.unbox(key: "courseNumber")
        self.courseDescription = try unboxer.unbox(key: "courseDescription")
        self.preReqNotes = try unboxer.unbox(key: "preReqNotes")
        self.synopsisUrl = try unboxer.unbox(key: "synopsisUrl")
        self.credits = try unboxer.unbox(key: "credits")
        self.sections = try unboxer.unbox(key: "sections")
        self.level = try unboxer.unbox(key: "level")
    }
}

extension Section: Unboxable {
    init(unboxer: Unboxer) throws {
        self.subtopic = try unboxer.unbox(key: "subtopic")
        self.subtitle = try unboxer.unbox(key: "subtitle")
        self.index = try unboxer.unbox(key: "index")
        self.number = try unboxer.unbox(key: "number")
        self.examCode = try unboxer.unbox(key: "examCode")
        self.printed = try unboxer.unbox(key: "printed")
        self.openStatus = try unboxer.unbox(key: "openStatus")
        self.sectionNotes = try unboxer.unbox(key: "sectionNotes")
        self.sessionDates = try unboxer.unbox(key: "sessionDates")
        self.sessionDatePrintIndicator =
            try unboxer.unbox(key: "sessionDatePrintIndicator")
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
        self.meetingDay = try unboxer.unbox(key: "meetingDay")
        self.meetingModeDesc = try unboxer.unbox(key: "meetingModeDesc")
        self.startTime = try unboxer.unbox(key: "startTime")
        self.endTime = try unboxer.unbox(key: "endTime")
        self.pmCode = try unboxer.unbox(key: "pmCode")
        self.campusAbbrev = try unboxer.unbox(key: "campusAbbrev")
        self.buildingCode = try unboxer.unbox(key: "buildingCode")
        self.roomNumber = try unboxer.unbox(key: "roomNumber")
    }
}

extension Init: Unboxable {
    init(unboxer: Unboxer) throws {
        self.currentTermDate = try unboxer.unbox(key: "currentTermDate")
        self.subjects = try unboxer.unbox(key: "subjects")
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
        self.description = try unboxer.unbox(key: "description")
        self.code = try unboxer.unbox(key: "code")
    }
}

//
//  SOCAPI.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/16/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Unbox

class SOCAPI {
    static let instance = SOCAPI()

    let provider: RxMoyaProvider<SOCService>

    fileprivate let networkVariable: Variable<NetworkActivityChangeType>
    var networkStatus: Observable<NetworkActivityChangeType> {
        get {
            return networkVariable.asObservable()
        }
    }

    private init() {
        let networkVariable = Variable(NetworkActivityChangeType.ended)
        self.provider = RxMoyaProvider<SOCService>(
            plugins: [NetworkActivityPlugin { [weak networkVariable] change in
                networkVariable?.value = change
            }, NetworkLoggerPlugin(verbose: true)]
        )
        self.networkVariable = networkVariable
    }

    public func getCourses(
        semester: Semester,
        campus: Campus
    ) -> Observable<[Course]> {
        return self.provider.request(
            .getCourses(semester: semester, campus: campus)
        ).map { response in
            guard
                let latin1String = String(
                    data: response.data,
                    encoding: .isoLatin1
                ),
                let utf8Data = latin1String.data(using: .utf8)
            else {
                throw SOCParseError.invalidValueFormat(
                    message: "Could not parse as latin1"
                )
            }

            return try unbox(data: utf8Data)
        }
    }

    public func getCourses(
        semester: Semester,
        campus: Campus,
        level: Level
    ) -> Observable<[Course]> {
        return getCourses(semester: semester, campus: campus).map { courses in
            courses.filter { $0.level == level }
        }
    }

    public func getInit() -> Observable<Init> {
        return self.provider.request(.getInit).mapUnboxObject(type: Init.self)
            .map { socInit in Init(
                currentTermDate: socInit.currentTermDate,
                subjects: socInit.subjects.map { subject in Subject(
                    subjectDescription: subject.subjectDescription
                        .trimmingCharacters(in: .whitespaces),
                    code: subject.code
                )}
            )}
    }

    public static func getSubjects(
        for courses: [Course],
        from subjects: [Subject]
    ) -> [Subject] {
        return subjects.filter { subject in
            courses.any { $0.subject == subject.code }
        }
    }
}

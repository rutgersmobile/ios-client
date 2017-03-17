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

    private init() {
        self.provider = RxMoyaProvider<SOCService>()
    }

    public func getCourses(
        semester: Semester,
        campus: Campus
    ) -> Observable<[Course]> {
        return self.provider.request(
            .getCourses(semester: semester, campus: campus)
        ).mapUnboxArray(type: Course.self)
    }

    public func getInit() -> Observable<Init> {
        return self.provider.request(.getInit).mapUnboxObject(type: Init.self)
    }
}

//
//  RutgersAPI.swift
//  Rutgers
//
//  Created by Matt Robinson on 1/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Moya
import Unbox
import RxSwift

class RutgersAPI {
    static let sharedInstance = RutgersAPI()

    let provider : RxMoyaProvider<RutgersService>

    private init() {
     //   self.provider = RxMoyaProvider<RutgersService>(plugins: [NetworkLoggerPlugin(verbose: true)])
        self.provider = RxMoyaProvider<RutgersService>()
    }
    
    public func getSOCInit() -> Observable<Init> {
        return self.provider.request(.getSOCInit).mapUnboxObject(type: Init.self)
    }
    
    public func getSubjects(semester: Semester, campus: Campus, level: Level) -> Observable<[Subject]> {
        return self.provider.request(.getSubjects(semester: semester, campus: campus, level: level))
            .mapUnboxArray(type: Subject.self)
    }
    
    public func getCourse(semester: Semester, campus: Campus, level: Level, course: Course) -> Observable<Course> {
        return self.provider.request(.getCourse(semester: semester, campus: campus, level: level, course: course))
            .mapUnboxObject(type: Course.self)
    }
    
    public func getCourses(semester: Semester, campus: Campus, level: Level, subject: Subject) -> Observable<[Course]> {
        return self.provider.request(.getCourses(semester: semester, campus: campus, level: level, subject: subject))
            .mapUnboxArray(type: Course.self)
    }
    
    public func getSections(semester: Semester, campus: Campus, level: Level, course: Course) -> Observable<[Section]> {
        return self.provider.request(.getSections(semester: semester, campus: campus, level: level, course: course))
            .mapUnboxArray(type: Section.self)
    }
    
    public func getDiningHalls() -> Observable<[DiningHall]> {
        return self.provider.request(.getDiningHalls)
            .mapUnboxArray(type: DiningHall.self)
    }

    public func getGamesForSport(sport: String) -> Observable<Sport> {
        return provider.request(.getGames(sport: sport))
            .mapUnboxObject(type: Sport.self)
    }
    
    public func getMotd() -> Observable<Motd> {
        return provider.request(.getMotd)
            .mapUnboxObject(type: Motd.self)
    }
    
    public func getOrderedContent() -> Observable<[Channel]> {
        return provider.request(.getChannel)
            .mapUnboxArray(type: Channel.self)
    }
    
    public func getAgency() -> Observable<AgencyConfig> {
        return provider.request(.getNBAgency)
            .mapUnboxObject(type: AgencyConfig.self)
    }
    
    public func getCinema() -> Observable<[Cinema]> {
        return provider.request(.getCinema)
            .mapUnboxArray(type: Cinema.self)
    }
}

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
    
    fileprivate let networkVariable: Variable<NetworkActivityChangeType>
    
    var networkStatus: Observable<NetworkActivityChangeType> {
        get {
            return networkVariable.asObservable()
        }
    }
    
    private init() {
        let networkVariable = Variable(NetworkActivityChangeType.ended)
        self.provider = RxMoyaProvider<RutgersService>(
            plugins: [NetworkActivityPlugin { [weak networkVariable] change in
                networkVariable?.value = change
                }, NetworkLoggerPlugin(verbose: true)]
        )
        
        self.networkVariable = networkVariable
    }
    
    public func getSOCInit() -> Observable<Init> {
        return self.provider
                   .request(
                        .getSOCInit
                    )
                    .mapUnboxObject(type: Init.self)
    }
    
    
    public func getBuilding(buildingCode: String) -> Observable<Building> {
        return self.provider
                   .request(
                        .getBuilding(buildingCode: buildingCode)
                    )
               .mapUnboxObject(type: Building.self)
    }
    
    public func getSubjects(semester: Semester,
                            campus: Campus,
                            level: Level)
        -> Observable<[Subject]> {
        return self.provider
                   .request(
                        .getSubjects(semester: semester,
                                     campus: campus,
                                     level: level)
                    )
                   .mapUnboxArray(type: Subject.self)
    }
    
    public func getCourse(
        semester: Semester,
        campus: Campus,
        level: Level,
        subject: Int,
        course: Int
    ) -> Observable<Course> {
        return self.provider.request(.getCourse(
            semester: semester,
            campus: campus,
            level: level,
            subject: subject,
            course: course)
        ).mapUnboxObject(type: Course.self)
    }
    
    public func getCourses(semester: Semester,
                           campus: Campus,
                           level: Level,
                           subject: Subject)-> Observable<[Course]> {
        return self.provider
                   .request(
                        .getCourses(semester: semester,
                                    campus: campus,
                                    level: level,
                                    subject: subject)
                        )
                   .mapUnboxArray(type: Course.self)
    }
    
    public func getSections(semester: Semester,
                            campus: Campus,
                            level: Level,
                            course: Course) -> Observable<[Section]> {
        return self.provider
            .request(
                .getSections(semester: semester,
                             campus: campus,
                             level: level,
                             course: course)
                )
            .mapUnboxArray(type: Section.self)
    }
    
    public func getSection(semester: Semester,
                           campus: Campus,
                           level: Level,
                           subjectNumber: Int,
                           courseNumber: Int,
                           sectionNumber: Int) -> Observable<[Section]> {
        return self.provider
                .request(
                .getSection(semester: semester,
                            campus: campus,
                            level: level,
                            subjectNumber: subjectNumber,
                            courseNumber: courseNumber,
                            sectionNumber: sectionNumber)
                ).mapUnboxArray(type: Section.self)
    }
    
    public func getSearch(semester: Semester,
                          campus: Campus,
                          level: Level,
                          query: String) -> Observable<SearchResults> {
        return self.provider
            .request(
                .getSearch(semester: semester,
                           campus: campus,
                           level: level,
                           query: query)
                )
            .mapUnboxObject(type: SearchResults.self)
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

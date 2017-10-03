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
    
    public func getSubjects(options: SOCOptions)
        -> Observable<[Subject]> {
        return self.provider
                   .request(
                    .getSubjects(options: options)
                    )
                   .mapUnboxArray(type: Subject.self)
    }
    
    public func getCourse(
        options: SOCOptions,
        subjectCode: Int,
        courseNumber: Int
    ) -> Observable<Course> {
        return self.provider.request(.getCourse(
            options: options,
            subjectCode: subjectCode,
            courseNumber: courseNumber)
        ).mapUnboxObject(type: Course.self)
    }
    
    public func getCourses(options: SOCOptions,
                           subjectCode: Int)-> Observable<[Course]> {
        return self.provider
                   .request(
                    .getCourses(options: options,
                                subjectCode: subjectCode)
                        )
                   .mapUnboxArray(type: Course.self)
    }
    
    public func getSections(options: SOCOptions,
                            subjectNumber: Int,
                            courseNumber: Int) -> Observable<[Section]> {
        return self.provider
            .request(
                .getSections(options: options,
                subjectNumber: subjectNumber,
                courseNumber: courseNumber)
                )
            .mapUnboxArray(type: Section.self)
    }
    
    public func getSearch(options: SOCOptions,
                          query: String) -> Observable<SearchResults> {
        return self.provider
            .request(
                .getSearch(options: options,
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

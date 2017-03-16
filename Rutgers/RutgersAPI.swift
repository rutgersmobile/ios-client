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
        self.provider = RxMoyaProvider<RutgersService>()
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

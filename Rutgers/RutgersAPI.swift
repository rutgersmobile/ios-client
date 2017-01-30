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
    
    public func getGamesForSport(sport: String) {
        provider.request(.getGames(sport: sport)) { result in
            switch result {
            case let .success(response):
                do {
                    let sport : Sport = try unbox(data: response.data)
                    print(sport)
                } catch {
                    print("Error parsing \(error)")
                }
            case let .failure(error):
                print("Error requesting \(error)")
            }
        }
        
    }
}

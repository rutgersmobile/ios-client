//
//  TmdbAPI.swift
//  Rutgers
//
//  Created by cfw37 on 2/8/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Moya
import Unbox
import RxSwift

class TmdbAPI {
    static let sharedInstance = TmdbAPI()
    
    let provider : RxMoyaProvider<TmdbService>
    
    private init() {
        self.provider = RxMoyaProvider<TmdbService>()
    }
    
    public func getTmdbData(movieId: Int) -> Observable<TmdbData> {
        return provider.request(.getTmdbData(movieId: movieId))
            .mapUnboxObject(type: TmdbData.self)
    }
}

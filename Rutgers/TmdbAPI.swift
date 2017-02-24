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
//        self.provider = RxMoyaProvider<TmdbService>(plugins: [NetworkLoggerPlugin(verbose: true)]) //Check what we're getting back from API
        self.provider = RxMoyaProvider<TmdbService>()
    }
    
    public func getTmdbData(movieId: Int) -> Observable<TmdbData> {
        return provider.request(.getTmdbData(movieId: movieId))
            .mapUnboxObject(type: TmdbData.self)
    }
    
    public func getTmdbCredits(movieId: Int) -> Observable<TmdbCredits> {
        return provider.request(.getCastCrew(movieId: movieId))
            .mapUnboxObject(type: TmdbCredits.self)
    }
    
    public func getPosterImage(data: TmdbData) -> Observable<UIImage?> {
        return ImageAPI.sharedInstance.getImage(reqUrl: URL(string: "http://image.tmdb.org/t/p/w500\(data.posterPath!)")!)
    }
    
    public func getCastProfilePicture(castData: Cast) -> Observable<UIImage?> {
        return ImageAPI.sharedInstance.getImage(reqUrl: URL(string: "http://image.tmdb.org/t/p/w185\(castData.profilePath!)")!)
    }
    
}

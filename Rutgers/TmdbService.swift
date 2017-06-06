//
//  TmdbService.swift
//  Rutgers
//
//  Created by cfw37 on 2/8/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum TmdbService {
    case getTmdbData(movieId: Int)
    case getCastCrew(movieId: Int)
}

extension TmdbService : TargetType {
    
    
    var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3/movie")!
    }
    
    var path: String {
        switch self {
        case .getTmdbData(let movieId):
            return "/\(movieId)"
        case .getCastCrew(let movieId):
            return "/\(movieId)/credits"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        
        //MOVE API KEY TO SECRET FILE
        
        switch self {
        case .getTmdbData( _):
            return ["api_key" : "a44c0fb255f2eca735d6ed30883fe27a", "append_to_response" : "videos"]
        case .getCastCrew( _):
            return ["api_key" : "a44c0fb255f2eca735d6ed30883fe27a", "language" : "en-US"]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return "test".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .getTmdbData, .getCastCrew:
             return .request
        }
    }
    

}

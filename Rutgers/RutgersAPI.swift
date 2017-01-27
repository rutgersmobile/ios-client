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

class RutgersAPI {
    static let sharedInstance = RutgersAPI()
    
    let provider : MoyaProvider<RutgersService>
    
    private init() {
        self.provider = MoyaProvider<RutgersService>()
    }

    public func getDiningHalls() {
        provider.request(.getDiningHalls) { result in
            switch result {
            case let .success(response):
                do {
                    let diningHalls: [DiningHall] = try unbox(data: response.data)
                    print(diningHalls)
                } catch {
                    print("Error parsing \(error)")
                }
            case let .failure(error):
                print("Error requesting \(error)")
            }
        }
    }
}

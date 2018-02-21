//
//  Observable+Unbox.swift
//  Rutgers
//
//  Created by Matt Robinson on 1/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import Unbox
import Moya

public extension ObservableType where E == Response {
    public func mapUnboxObject<T: Unboxable>(type: T.Type) -> Observable<T> {
        return map { response -> T in
            return try unbox(data: response.data)
        }
    }

    public func mapUnboxArray<T: Unboxable>(type: T.Type) -> Observable<[T]> {
        return map { response -> [T] in
            return try unbox(data: response.data)
        }
    }
}

//
//  Observable+RUAdditions.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/24/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    func filterMap<R>(transform: @escaping (E) -> R?) -> Observable<R> {
        return Observable.create { observer in
            self.subscribe { e in
                switch e {
                case .next(let x):
                    if let y = transform(x) {
                        observer.on(.next(y))
                    }
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }
    }
}

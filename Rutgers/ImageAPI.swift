//
//  ImageAPI.swift
//  Rutgers
//
//  Created by cfw37 on 2/13/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift

class ImageAPI {
    static let sharedInstance = ImageAPI()
    
    public func getImage(reqUrl: URL) -> Observable<UIImage?> {
        
        let req = URLRequest(url: reqUrl)
        
        return URLSession.shared.rx.response(request: req).map({ (response, data) in
            return UIImage(data: data)
        })
    }
    
}

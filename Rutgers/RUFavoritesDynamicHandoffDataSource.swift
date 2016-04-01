//
//  RUFavoritesDynamicHandoffDataSource.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 3/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import UIKit

class RUFavoritesDynamicHandoffDataSource: DataSource {
    let pathComponents: [String]
    let handle: String
    
    var result: NSDictionary?
    
    init(handle: String, pathComponents: [String]) {
        self.handle = handle
        self.pathComponents = pathComponents
    }
    
    override func loadContent() {
        loadContentWithBlock { loading in
            do {
                let channel = try self.findChannelForPathComponents(self.pathComponents)
                loading.updateWithContent { weakSelf in
                    (weakSelf as! RUFavoritesDynamicHandoffDataSource).result = channel
                }
            } catch {
                loading.doneWithError(error as NSError)
            }
        }
    }
    
    func findChannelForPathComponents(pathComponents: [String]) throws -> NSDictionary {
        guard pathComponents.count > 0 else { throw RutgersError.InvalidPath }
        
        var mutableComponents = pathComponents
        let component = mutableComponents.removeFirst()
        
        let channel = RUChannelManager.sharedInstance().channelWithHandle(component) as NSDictionary
        
        let url = channel.channelURL
        
        
        
        throw RutgersError.InvalidPath
    }
}

public enum RutgersError: ErrorType {
    case InvalidPathComponent
    case InvalidPath
}

public let RutgersErrorDomain = "RutgersErrorDomain"

public extension NSError {
    convenience init(invalidPathComponent: String) {
        self.init(domain: RutgersErrorDomain, code: 666, userInfo: ["pathComponent": invalidPathComponent])
    }
}



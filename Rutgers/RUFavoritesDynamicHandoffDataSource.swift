//
//  RUFavoritesDynamicHandoffDataSource.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 3/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import UIKit

class RUFavoritesDynamicHandoffDataSource: DataSource, DataSourceDelegate {
    var remainingPathComponents: [String]
    let handle: String
    
    var currentDataSource: DynamicDataSource
    
    var resultTitle: String?
    var result: [NSObject: AnyObject]?
    var error: Error?

    var loading: AAPLLoading?
    
    init(handle: String, pathComponents: [String]) {
        print(handle)
        self.handle = handle
        self.remainingPathComponents = pathComponents
        let currentChannel = RUChannelManager.sharedInstance().channel(withHandle: handle)
        currentDataSource = DynamicDataSource(channel: currentChannel)
    }
    
    override func loadContent() {
        self.loadContent { loading in
            self.loading = loading
            self.startIteration()
        }
    }

    func startIteration() {
        currentDataSource.delegate = self
        currentDataSource.loadContent()
    }
    
    func finishWithDataSource(dataSource: DynamicDataSource) {
        self.result = dataSource.channel as [NSObject : AnyObject]?
        self.loading?.done()
        self.loading = nil
    }
    
    func finishWithError(error: Error?) {
        if error is DynamicFavoriteError {
            self.errorTitle = "Favorites Error"
            self.errorMessage = "Your favorite could not be loaded"
            self.errorButtonTitle = nil
        }
        
        self.error = error
        self.loading?.doneWithError(error as NSError?)
        self.loading = nil
    }
   
    
   // Point of error
    
    func dataSource(_ dataSource: DataSource, didLoadContentWithError error: Error!) {
        do {
            try findMatchingSubItemInDataSource(dataSource: dataSource)
            print("working !!")
        } catch {
            finishWithError(error: error)
            print("error")
        }
    }
    
    func findMatchingSubItemInDataSource(dataSource: DataSource) throws {
        if let dataSource = dataSource as? BasicDataSource {
            let nextComponent = remainingPathComponents.removeFirst()
            guard let channel: [NSObject : AnyObject] = dataSource.subitemMatchingPathComponent(pathComponent: nextComponent) as [NSObject : AnyObject]?
                else { throw DynamicFavoriteError.InvalidPathComponent }

            if let actualChannel = channel["channel" as NSObject] as? [NSObject: AnyObject] {
                currentDataSource = DynamicDataSource(channel: actualChannel)
            } else {
                currentDataSource = DynamicDataSource(channel: channel)
            }
            

            if remainingPathComponents.count == 0 {
                finishWithDataSource(dataSource: currentDataSource)
            } else {
                startIteration()
            }
            print(dataSource.items)
        }
    }
}

extension BasicDataSource {
    func subitemMatchingPathComponent(pathComponent: String) -> [NSObject: AnyObject]? {
        for case let subItem as NSDictionary in items {
            guard let title = subItem.channelTitle else { continue }
            let normalizedTitle = (title as NSString).rutgersStringEscape()
            if normalizedTitle == pathComponent {
                return subItem as [NSObject : AnyObject]
            }
        }
        return nil
    }
}

public enum DynamicFavoriteError: Error {
    case InvalidPathComponent
    case InvalidPath
}


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
    var error: ErrorType?
    
    var loading: AAPLLoading?
    
    init(handle: String, pathComponents: [String]) {
        self.handle = handle
        self.remainingPathComponents = pathComponents
        let currentChannel = RUChannelManager.sharedInstance().channelWithHandle(handle)
        currentDataSource = DynamicDataSource(channel: currentChannel)
    }
    
    override func loadContent() {
        loadContentWithBlock { loading in
            self.loading = loading
            self.startIteration()
        }
    }
    
    func startIteration() {
        currentDataSource.delegate = self
        currentDataSource.loadContent()
    }
    
    func finishWithDataSource(dataSource: DynamicDataSource) {
        self.result = dataSource.channel
        self.loading?.done()
        self.loading = nil
    }
    
    func finishWithError(error: ErrorType?) {
        if error is DynamicFavoriteError {
            self.errorTitle = "Favorites Error"
            self.errorMessage = "Your favorite could not be loaded"
            self.errorButtonTitle = nil
        }
        
        self.error = error
        self.loading?.doneWithError(error as? NSError)
        self.loading = nil
    }
   
    
   // Point of error
    
    func dataSource(dataSource: DataSource!, didLoadContentWithError error: NSError!) {
        do {
            try findMatchingSubItemInDataSource(dataSource)
            print("working !!")
        } catch {
            finishWithError(error)
            print("error")
        }
    }
    
    func findMatchingSubItemInDataSource(dataSource: DataSource) throws {
        if let dataSource = dataSource as? BasicDataSource {
            let nextComponent = remainingPathComponents.removeFirst()
            guard let channel = dataSource.subitemMatchingPathComponent(nextComponent)
                else { throw DynamicFavoriteError.InvalidPathComponent }

            if let actualChannel = channel["channel"] as? [NSObject: AnyObject] {
                currentDataSource = DynamicDataSource(channel: actualChannel)
            } else {
                currentDataSource = DynamicDataSource(channel: channel)
            }
            

            if remainingPathComponents.count == 0 {
                finishWithDataSource(currentDataSource)
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
                return subItem as? [NSObject: AnyObject]
            }
        }
        return nil
    }
}

public enum DynamicFavoriteError: ErrorType {
    case InvalidPathComponent
    case InvalidPath
}


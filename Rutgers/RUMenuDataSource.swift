//
//  RUMenuDataSource.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

open class RUMenuDataSource: ComposedDataSource {
    let activeMenuItemsDataSource: RUMenuBasicDataSource
    
    override init() {
        activeMenuItemsDataSource = RUMenuBasicDataSource()
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RUMenuDataSource.setNeedsLoadContent), name: NSNotification.Name(rawValue: MenuItemManagerDidChangeActiveMenuItemsKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RUMenuDataSource.setNeedsLoadContent), name: NSNotification.Name(rawValue: ChannelManagerDidUpdateChannelsKey), object: nil)

        activeMenuItemsDataSource.items = RUMenuItemManager.sharedManager.menuItems
        
        let otherItemsDataSource = RUMenuBasicDataSource()
        otherItemsDataSource.items = RUChannelManager.sharedInstance().otherChannels
        
        add(activeMenuItemsDataSource)
        add(otherItemsDataSource)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func loadContent() {
        super.loadContent()
        activeMenuItemsDataSource.items = RUMenuItemManager.sharedManager.menuItems
    }
}

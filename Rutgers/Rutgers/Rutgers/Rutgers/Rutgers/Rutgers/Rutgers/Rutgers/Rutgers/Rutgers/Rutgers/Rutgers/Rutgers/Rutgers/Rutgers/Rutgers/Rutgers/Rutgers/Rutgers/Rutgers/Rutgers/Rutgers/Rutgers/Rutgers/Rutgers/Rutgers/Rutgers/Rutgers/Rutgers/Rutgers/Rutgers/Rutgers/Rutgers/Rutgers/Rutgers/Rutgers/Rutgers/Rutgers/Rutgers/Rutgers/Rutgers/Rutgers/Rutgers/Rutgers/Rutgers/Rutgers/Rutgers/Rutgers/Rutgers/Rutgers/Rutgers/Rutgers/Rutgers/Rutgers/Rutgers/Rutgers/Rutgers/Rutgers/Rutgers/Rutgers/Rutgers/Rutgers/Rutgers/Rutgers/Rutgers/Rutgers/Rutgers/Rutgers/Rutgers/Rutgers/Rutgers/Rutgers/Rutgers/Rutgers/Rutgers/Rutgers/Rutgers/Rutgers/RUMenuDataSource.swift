//
//  RUMenuDataSource.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

public class RUMenuDataSource: ComposedDataSource {
    let activeMenuItemsDataSource: RUMenuBasicDataSource
    
    override init() {
        activeMenuItemsDataSource = RUMenuBasicDataSource()
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RUMenuDataSource.setNeedsLoadContent), name: MenuItemManagerDidChangeActiveMenuItemsKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RUMenuDataSource.setNeedsLoadContent), name: ChannelManagerDidUpdateChannelsKey, object: nil)

        activeMenuItemsDataSource.items = RUMenuItemManager.sharedManager.menuItems
        
        let otherItemsDataSource = RUMenuBasicDataSource()
        otherItemsDataSource.items = RUChannelManager.sharedInstance().otherChannels
        
        addDataSource(activeMenuItemsDataSource)
        addDataSource(otherItemsDataSource)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func loadContent() {
        super.loadContent()
        activeMenuItemsDataSource.items = RUMenuItemManager.sharedManager.menuItems
    }
}
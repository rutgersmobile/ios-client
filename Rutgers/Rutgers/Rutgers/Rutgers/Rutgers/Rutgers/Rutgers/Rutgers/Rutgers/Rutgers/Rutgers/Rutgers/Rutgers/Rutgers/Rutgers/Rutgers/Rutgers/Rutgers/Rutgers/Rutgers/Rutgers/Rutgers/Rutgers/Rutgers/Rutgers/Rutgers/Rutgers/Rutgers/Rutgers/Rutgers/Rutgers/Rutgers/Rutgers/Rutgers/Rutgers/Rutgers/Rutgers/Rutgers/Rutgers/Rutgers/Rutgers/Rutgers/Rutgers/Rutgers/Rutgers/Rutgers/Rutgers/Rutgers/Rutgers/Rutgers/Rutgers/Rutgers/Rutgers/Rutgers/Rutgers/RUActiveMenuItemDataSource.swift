//
//  RUActiveMenuItemDataSource.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

class RUMenuBasicDataSource: BasicDataSource {
    override func registerReusableViewsWithTableView(tableView: UITableView!) {
        super.registerReusableViewsWithTableView(tableView)
        tableView.registerClass(RUMenuTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(RUMenuTableViewCell.self))
    }

    override func reuseIdentifierForRowAtIndexPath(indexPath: NSIndexPath!) -> String! {
        return NSStringFromClass(RUMenuTableViewCell.self)
    }
    
    override func configureCell(cell: AnyObject!, forRowAtIndexPath indexPath: NSIndexPath!) {
        let item = itemAtIndexPath(indexPath)
        let menuCell = cell as! RUMenuTableViewCell
        
        //warning move this into the cell
        switch item {
        case let favorite as RUFavorite:
            if let handle = favorite.channelHandle, channel = RUChannelManager.sharedInstance().channelWithHandle(handle) {
                menuCell.setupForChannel(channel)
                menuCell.channelTitleLabel.text = favorite.title
            }
        case let channel as [NSObject : AnyObject]:
            menuCell.setupForChannel(channel)
        default: return
        }
    }
    
    override func configurePlaceholderCell(cell: ALPlaceholderCell!) {
        super.configurePlaceholderCell(cell)
        cell.backgroundColor = UIColor.clearColor()
    }
}
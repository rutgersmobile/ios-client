//
//  RUActiveMenuItemDataSource.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

class RUMenuBasicDataSource: BasicDataSource {
    override func registerReusableViews(with tableView: UITableView!) {
        super.registerReusableViews(with: tableView)
        tableView.register(RUMenuTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(RUMenuTableViewCell.self))
    }

    override func reuseIdentifierForRow(at indexPath: IndexPath!) -> String! {
        return NSStringFromClass(RUMenuTableViewCell.self)
    }
    
    override func configureCell(_ cell: Any!, forRowAt indexPath: IndexPath!) {
        let indexItem = item(at: indexPath)
        let menuCell = cell as! RUMenuTableViewCell

        //warning move this into the cell
        switch indexItem {
        case let favorite as RUFavorite:
            if let handle = favorite.channelHandle, let channel = RUChannelManager.sharedInstance().channel(withHandle: handle) {
                menuCell.setup(forChannel: channel)
                menuCell.channelTitleLabel.text = favorite.title
            }
        case let channel as [NSObject : AnyObject]:
            menuCell.setup(forChannel: channel)
        default: return
        }
    }
    
    override func configurePlaceholderCell(_ cell: ALPlaceholderCell!) {
        super.configurePlaceholderCell(cell)
        cell.backgroundColor = UIColor.clear
    }
}

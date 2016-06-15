//
//  RUEditMenuItemsViewController.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

class RUEditMenuItemsViewController: TableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.editing = true
        title = "Edit Channels"
        
        let editDataSource = RUEditMenuItemsDataSource()
        dataSource = editDataSource
        
        //navigationItem.rightBarButtonItem = editButtonItem()
        
        let imageView = UIImageView(image: UIImage(named: "bg"))
        imageView.contentMode = .ScaleToFill
        tableView.backgroundView = imageView
        tableView.separatorColor = UIColor.clearColor()
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .Delete
        } else {
            return .Insert
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        let item = dataSource.itemAtIndexPath(indexPath)
        if item is RUFavorite {
            return "Delete"
        } else {
            return "Hide"
        }
    }
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        let item = dataSource.itemAtIndexPath(sourceIndexPath)
        if item is RUFavorite && proposedDestinationIndexPath.section == 1 {
            return NSIndexPath(forRow: dataSource.numberOfItemsInSection(0) - 1, inSection: 0)
        } else {
            return proposedDestinationIndexPath
        }
    }
}

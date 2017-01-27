//
//  RUEditMenuItemsViewController.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

class RUEditMenuItemsViewController: TableViewController , RUChannelProtocol {

    static func channelHandle() -> String!
    {
       return "edit";
    }

 // temp solution
    
/*
        Every class is register with the RUChannelManager by calling a register class static method in the load function of each class.
        The load is called in objc on every class by the run time library...
        The load handles the registration process .
 */
    static func registerClass()
    {
            RUChannelManager.sharedInstance().register(RUEditMenuItemsViewController.self)
    }

    public static func channel(withConfiguration channelConfiguration: [AnyHashable : Any]!) -> Any! {
        return RUEditMenuItemsViewController(style: .grouped);
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.isEditing = true
        title = "Edit Channels"
        
        tableView.allowsSelectionDuringEditing = false ;
        
        let editDataSource = RUEditMenuItemsDataSource()
        dataSource = editDataSource
       
        // Set the background image for the edit channels
        let imageView = UIImageView(image: UIImage(named: "bg"))
        imageView.contentMode = .scaleToFill
        tableView.backgroundView = imageView
        tableView.separatorColor = UIColor.clear
        

        // Add edit button :: No need for the edit button as the view controller opens in the edit mode and the changes are saved ..
      //  self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .delete
        } else {
            return .insert
        }
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let item = dataSource.item(at: indexPath as IndexPath!)
        if item is RUFavorite {
            return "Delete"
        } else {
            return "Hide"
        }
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let item = dataSource.item(at: sourceIndexPath as IndexPath!)
        if item is RUFavorite && proposedDestinationIndexPath.section == 1 {
            return IndexPath(row: dataSource.numberOfItems(inSection: 0) - 1, section: 0)
        } else {
            return proposedDestinationIndexPath
        }
    }
   
   //    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
   //        return nil;
   //    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        let item = self.dataSource .item(at: indexPath as IndexPath!) as AnyObject
        
        if item is RUFavorite
        {
            //print(item.url!!.absoluteString)
        }
        else
        {
            print(item.self)
            print(item.channelURL)
            print(item.channelHandle)
            print()
        }
    }
    
    internal func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool
    {
        return true
    }
 
    
    
    
    
    
    
}

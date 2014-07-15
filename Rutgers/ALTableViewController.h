//
//  ALTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALTableViewAbstractCell;

@interface ALTableViewController : UITableViewController <UISearchDisplayDelegate>
-(id)layoutViewForIdentifier:(NSString *)identifier;
-(NSString *)identifierForCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;

-(NSString *)identifierForHeaderInTableView:(UITableView *)tableView;


@property (nonatomic) UISearchDisplayController *searchController;
-(void)enableSearch;
@end

//
//  TableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"
#import "SearchDataSource.h"

/**
 *  The generic Table View superclass
 *  This contains all the logic for displaying a table view onscreen, with its information provided by a data source
 *  Just make the data source, set it on the view controller, and you are done
 */
@interface TableViewController : UITableViewController <UITableViewDelegate, DataSourceDelegate>
@property (nonatomic) DataSource *dataSource;

@property (nonatomic) DataSource<SearchDataSource> *searchDataSource;
@property (nonatomic, readonly, strong) UITableView *searchTableView;

@property (nonatomic, readonly) NSURL *sharingURL;
@property (nonatomic, readonly) NSString *handle;

@property (nonatomic) BOOL pullsToRefresh;

/**
 *  Whether or not a row should be highlighted
 *  This base implementation will return NO if the row is a placeholder, which you cant tap on
 *  So in a subclass call super and if it returns NO, you should return no
 *  @return NO if its a placeholder, YES otherwise
 */
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;

/**
 *  This is for a more sophisticated analytics system that details all the user interaction events
 *  Here you would recieve the row that was tapped on, and return details about it to send to the analytics server
 *  @return A dictionary containing details about what was tapped
 */
-(NSDictionary *)userInteractionForTableView:(UITableView *)tableView rowAtIndexPath:(NSIndexPath *)indexPath;
@end

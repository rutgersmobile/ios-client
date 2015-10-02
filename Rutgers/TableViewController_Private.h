//
//  TableViewController_Private.h
//  Rutgers
//
//  Created by Kyle Bailey on 9/4/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TableViewController.h"

/**
 *  The private interface to TableViewController, contains stuff that needs to be exposed for subclasses to use
 */
@interface TableViewController ()

/**
 *  Property if the search controller is set up, and a method to set it up if it is not
 *  You should only call enable search if search is not enabled and the dont call it again
 *  Honestly this should not be public, it should be more like a enableSearchIfNeeded method
 *  And then searchEnabled would be a private property
 */
#warning make changes specified in above description
@property (nonatomic) BOOL searchEnabled;
-(void)enableSearch;

/**
 *  Overload these methods in the subclass to be notified when search will be presented or dismissed
 *  Should be renamed to searchWillPresent, searchDidDismiss etc
 */
#warning make changes specified in above description
-(void)presentSearch NS_REQUIRES_SUPER;
-(void)dismissSearch NS_REQUIRES_SUPER;

/**
 *  Override this to specify changes to be made when the width has changed
 *  For example, throw out the row height cache, resize the segmented control
 */
-(void)viewDidChangeWidth;

/**
 *  Set this to yes, and the view controller will refresh every time it appears onscreen
 */
@property (nonatomic) BOOL loadsContentOnViewWillAppear;

/**
 *  Accessors to easily find the data source corresponding to a table view, or table view corresponding to data source
 *  Use to distinguish things happing in the default table, or the search table
 */
-(DataSource *)dataSourceForTableView:(UITableView *)tableView;
-(UITableView *)tableViewForDataSource:(DataSource *)dataSource;

/**
 *  Used to remember if we are searching
 */
@property (nonatomic, getter = isSearching) BOOL searching;
@property (nonatomic) UISearchBar *searchBar;

/**
 *  The users desired font size has changed
 */
-(void)preferredContentSizeChanged NS_REQUIRES_SUPER;

/**
 *  Reload the table, remembering what was selected
 */
-(void)reloadTablePreservingSelectionState:(UITableView *)tableView;

/**
 *  Return the proper animation to use for a particular animation direction
 *
 *  @param direction Left, Right, or none
 *
 *  @return The animation enum value you wish to use
 */
-(UITableViewRowAnimation)rowAnimationForOperationDirection:(DataSourceAnimationDirection)direction;
@end

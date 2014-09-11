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

@interface TableViewController : UIViewController <UITableViewDelegate, UISearchDisplayDelegate>
-(instancetype)initWithStyle:(UITableViewStyle)style;

@property (nonatomic) UITableView *tableView;
-(UITableView *)searchTableView;
@end

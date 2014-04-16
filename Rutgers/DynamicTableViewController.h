//
//  DynamicTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
 
@interface DynamicTableViewController : UITableViewController
@property (nonatomic) NSArray *children;
-(id)initWithStyle:(UITableViewStyle)style children:(NSArray *)children;
@end

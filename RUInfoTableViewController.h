//
//  RUInfoTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RUComponentDelegate;

@interface RUInfoTableViewController : UITableViewController

@property (nonatomic) id <RUComponentDelegate> delegate;

@end

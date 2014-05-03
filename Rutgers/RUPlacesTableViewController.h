//
//  RUPlacesTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUComponentDelegate.h"

@interface RUPlacesTableViewController : UITableViewController
@property (nonatomic) id <RUComponentDelegate> delegate;
- (id) initWithDelegate: (id <RUComponentDelegate>) delegate;
@end

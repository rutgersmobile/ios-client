//
//  RUPlacesTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUPlacesDelegate.h"

@interface RUPlacesTableViewController : UITableViewController
@property (nonatomic) id <RUPlacesDelegate> delegate;
- (id) initWithDelegate: (id <RUPlacesDelegate>) delegate;
@end

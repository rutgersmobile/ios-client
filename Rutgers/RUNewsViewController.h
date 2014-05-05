//
//  RUNewsViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUComponentDelegate.h"
#import "DynamicTableViewController.h"

@interface RUNewsViewController : DynamicTableViewController
@property (nonatomic) id <RUComponentDelegate> delegate;
- (id) initWithDelegate: (id <RUComponentDelegate>) delegate;
@end
  
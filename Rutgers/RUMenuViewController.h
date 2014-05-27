//
//  RUMenuViewController.h
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RURootController.h"

@interface RUMenuViewController : UITableViewController
@property id <RUMenuDelegate> delegate;
@end

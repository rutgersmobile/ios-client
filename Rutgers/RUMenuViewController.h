//
//  RUMenuViewController.h
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RURootViewController.h"

@interface RUMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property id <RUMenuDelegate> delegate;
@end



//
//  RUBusNumberViewController.h
//  Rutgers
//
//  Created by cfw37 on 1/18/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandingTableViewController.h"

@interface RUBusNumberViewController : ExpandingTableViewController

-(instancetype)initWithItem:(id)item;
-(instancetype)initWithItem:(id)item busNumber:(NSString*)busNumber;

@end

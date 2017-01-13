//
//  RUBusNumberViewController.h
//  Rutgers
//
//  Created by cfw37 on 1/12/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

#import "ExpandingTableViewController.h"

@interface RUBusNumberViewController : ExpandingTableViewController

-(instancetype)initWithItem:(id)item;
-(instancetype)initWithSerializedItem:(id)item title:(NSString *)title;

@end

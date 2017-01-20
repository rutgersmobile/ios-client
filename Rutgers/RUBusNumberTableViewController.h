//
//  RUBusNumberTableViewController.h
//  Rutgers
//
//  Created by cfw37 on 1/13/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUBusPrediction.h"

@interface RUBusNumberTableViewController : UITableViewController

@property (nonatomic) id item;
@property (nonatomic) NSString* busNumber;

-(instancetype)initWithItem:(id)item busNumber:(NSString*)busNumber;


@end

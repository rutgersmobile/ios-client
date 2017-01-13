//
//  RUBusNumberTableViewController.h
//  Rutgers
//
//  Created by cfw37 on 1/12/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUBusRoute.h"


@interface RUBusNumberTableViewController : UITableViewController

@property (nonatomic) NSArray* predictionTimes;
@property (nonatomic) RUBusRoute* routeObject;

@end

//
//  RUPredictionsViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RUBusRoute;
@class RUBusData;

@interface RUPredictionsViewController : UITableViewController
@property (nonatomic) NSArray *stops;
@property (nonatomic) RUBusRoute *route;
@property (nonatomic) RUBusData *busData;
@property (nonatomic) NSString *agency;
@end

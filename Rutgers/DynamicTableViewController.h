//
//  DynamicTableViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TableViewController.h"
#import "RUChannelProtocol.h"

/*
 *
 *  This is the class used to display dynamic information  // json form
 */
@interface DynamicTableViewController : TableViewController <RUChannelProtocol>

+(NSURL *)buildDynamicSharingURL:(UINavigationController*)navigationController channel:(NSDictionary*)channel;
@end

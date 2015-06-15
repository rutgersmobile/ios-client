//
//  ActiveStopsDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BusBasicDataSource.h"

@interface ActiveStopsDataSource : BusBasicDataSource
- (instancetype)initWithAgency:(NSString *)agency NS_DESIGNATED_INITIALIZER;

@end

//
//  ActiveRoutesDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BusBasicDataSource.h"

@interface ActiveRoutesDataSource : BusBasicDataSource
- (instancetype)initWithAgency:(NSString *)agency;
@end

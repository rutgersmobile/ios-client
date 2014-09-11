//
//  DynamicDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"

@interface DynamicDataSource : BasicDataSource
-(instancetype)initWithChannel:(NSDictionary *)channel;
@end

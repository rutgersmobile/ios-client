//
//  RUSOCCourseDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"

@interface RUSOCCourseDataSource : ComposedDataSource
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithCourse:(NSDictionary *)course NS_DESIGNATED_INITIALIZER;
@end

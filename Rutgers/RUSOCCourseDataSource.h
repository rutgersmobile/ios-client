//
//  RUSOCCourseDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"

@interface RUSOCCourseDataSource : ComposedDataSource
-(id)initWithCourse:(NSDictionary *)course;
@end

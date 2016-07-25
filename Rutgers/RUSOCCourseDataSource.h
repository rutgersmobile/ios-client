//
//  RUSOCCourseDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"
#import "RUSOCDataLoadingManager.h"

@interface RUSOCCourseDataSource : ComposedDataSource
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithCourse:(NSDictionary *)course dataLoadingManager:(RUSOCDataLoadingManager *)dataLoadingManager NS_DESIGNATED_INITIALIZER;
@property (nonatomic) NSString * courseTitle ; // used to set the title when we are deep linking...
@end

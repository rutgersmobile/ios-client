//
//  RURecCenterDataSource.h
//  Rutgers
//
//  Created by Open Systems Solutions on 1/16/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "ComposedDataSource.h"
#import "RURecCenterHoursSection.h"
#import "RUPlace.h"

@interface RURecCenterDataSource : ComposedDataSource
@property (nonatomic) RURecCenterHoursSection *hoursSection;
-(instancetype)initWithRecCenter:(NSDictionary *)recCenter NS_DESIGNATED_INITIALIZER;
@end

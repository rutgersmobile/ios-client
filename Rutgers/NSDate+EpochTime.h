//
//  NSDate+EpochTime.h
//  Rutgers
//
//  Created by Open Systems Solutions on 2/4/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (EpochTime)
+(NSDate *)dateWithEpochTime:(NSString *)epochTime;
@end

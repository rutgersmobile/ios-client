//
//  RUSportsData.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUSportsData : NSObject
//+(RUSportsData *)sharedInstance;
+(NSDictionary *)allSports;
+(void)getRosterForSportID:(NSString *)sportID withSuccess:(void (^)(NSArray *response))successBlock failure:(void (^)(void))failureBlock;
+(void)getScheduleForSportID:(NSString *)sportID withSuccess:(void (^)(NSArray *response))successBlock failure:(void (^)(void))failureBlock;
@end

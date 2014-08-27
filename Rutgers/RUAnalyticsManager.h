//
//  RUAnalyticsManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUAnalyticsManager : NSObject
+(void)postAnalyticsForNewInstall;
+(void)postAnalyticsForAppStartup;
+(void)postAnalyticsForError:(NSError *)error;
+(void)postAnalyticsForChannelOpen:(NSDictionary *)channel;
+(void)postAnalyticsForEvent:(NSDictionary *)event;
@end

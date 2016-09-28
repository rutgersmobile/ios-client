//
//  RUAnalyticsManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUDefines.h"

static NSString * const CrashKey = @"CRASH_REPORT";


@interface RUAnalyticsManager : NSObject
+(instancetype)sharedManager;

//Events are put in a queue to be flushed to reduce network useage
-(void)queueEventForApplicationLaunch;
-(void)queueEventForError:(NSError *)error;
-(void)queueEventForChannelOpen:(NSDictionary *)channel;

-(void)queueClassStrForExceptReporting:(NSString *)className;
-(void)saveException:(NSException*) exception;

//Not yet implemented
-(void)queueEventForUserInteraction:(NSDictionary *)userInteraction;
-(void)postAnalyticsEvents:(NSArray *)events;

@end

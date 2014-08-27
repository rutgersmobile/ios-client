//
//  RUAnalyticsManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUAnalyticsManager.h"

@implementation RUAnalyticsManager
+(void)postAnalyticsForNewInstall{
    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"fresh_launch"
                                      }];
    [self postAnalyticsEvent:event];
}

+(void)postAnalyticsForAppStartup{
    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"launch"
                                      }];
    [self postAnalyticsEvent:event];
}

+(void)postAnalyticsForError:(NSError *)error{
    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"error"
                                      }];
    [self postAnalyticsEvent:event];
}

+(void)postAnalyticsForChannelOpen:(NSDictionary *)channel{
    NSMutableDictionary *event = [self baseEvent];
    NSString *channelHandle = [channel channelHandle];
    if (!channelHandle) return;
    
    [event addEntriesFromDictionary:@{
                                      @"type" : @"channel",
                                      @"handle" : channelHandle
                                      }];
    [self postAnalyticsEvent:event];
}

+(void)postAnalyticsForEvent:(NSDictionary *)event{
    NSMutableDictionary *baseEvent = [self baseEvent];
    [baseEvent addEntriesFromDictionary:@{
                                      @"type" : @"event"
                                      }];
    [self postAnalyticsEvent:event];
}

+(NSMutableDictionary *)baseEvent{
    RUUserInfoManager *infoManager = [RUUserInfoManager sharedInstance];
    return [@{
              @"date" : [NSString stringWithFormat:@"@%ld",((long)[NSDate date].timeIntervalSince1970)],
              @"role" : infoManager.userRole[@"title"],
              @"campus" : infoManager.campus[@"title"],
              @"platform" : [self platform],
              @"release" : [self releaseDict]
              } mutableCopy];
}

+(NSDictionary *)platform{
    UIDevice *device = [UIDevice currentDevice];
    return @{
             @"id" : device.identifierForVendor.UUIDString,
             @"os" : device.systemName,
             @"model" : device.model,
             @"tablet" : @(iPad()),
             @"version" : device.systemVersion
             };
}

+(NSDictionary *)releaseDict{
    return @{
             @"beta" : @(BETA)
             };
}

+(void)postAnalyticsEvent:(NSDictionary *)event{
    NSString *url = @"analytics.php";
    url = @"http://sauron.rutgers.edu/~jamchamb/analytics.php";
    
    [[RUNetworkManager sessionManager] POST:url parameters:@{@"payload" : [self payloadStringForEvents:@[event]]} success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

+(NSString *)payloadStringForEvents:(NSArray *)events{
    NSData *data = [NSJSONSerialization dataWithJSONObject:events options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end

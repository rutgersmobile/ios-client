//
//  RUAnalyticsManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUAnalyticsManager.h"

@interface RUAnalyticsManager ()
@property NSMutableArray *queue;
@property NSTimer *flushTimer;
@property BOOL firstLaunch;
@end

@implementation RUAnalyticsManager
+(instancetype)sharedManager{
    static RUAnalyticsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RUAnalyticsManager alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = [NSMutableArray array];
    }
    return self;
}

static NSString *const kAnalyticsManagerFirstLaunchKey = @"kAnalyticsManagerFirstLaunchKey";

-(BOOL)firstLaunch{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kAnalyticsManagerFirstLaunchKey : @(YES)}];
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAnalyticsManagerFirstLaunchKey];
}

-(void)setFirstLaunch:(BOOL)firstLaunch{
    [[NSUserDefaults standardUserDefaults] setBool:firstLaunch forKey:kAnalyticsManagerFirstLaunchKey];
}


-(void)queueEventForFirstLaunch{
    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"fresh_launch"
                                      }];
    [self queueAnalyticsEvent:event];
}

-(void)queueEventForApplicationLaunch{
    if (self.firstLaunch) {
        [self queueEventForFirstLaunch];
        self.firstLaunch = NO;
    }
    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"launch"
                                      }];
    [self queueAnalyticsEvent:event];
}

-(void)queueEventForError:(NSError *)error{
    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"error",
                                      @"error" : error.localizedDescription
                                      }];
    [self queueAnalyticsEvent:event];
}

-(void)queueEventForChannelOpen:(NSDictionary *)channel{
    NSString *channelHandle = [channel channelHandle];
    if (!channelHandle) return;
    
    NSMutableDictionary *event = [self baseEvent];
    
    [event addEntriesFromDictionary:@{
                                      @"type" : @"channel",
                                      @"handle" : channelHandle
                                      }];
    [self queueAnalyticsEvent:event];
}

#warning this is a stub that must be expanded
-(void)queueEventForUserInteraction:(NSDictionary *)userInteraction{
    return;
    /*
    NSMutableDictionary *event = [self baseEvent];
    event[@"userInteraction"] = userInteraction;
    [self queueAnalyticsEvent:event];
    NSLog(@"%@",event);*/
}

-(NSMutableDictionary *)baseEvent{
    NSMutableDictionary *baseEvent = [@{
                                       @"date" : [NSString stringWithFormat:@"@%ld",((long)[NSDate date].timeIntervalSince1970)],
                                       @"platform" : [self platform],
                                       @"release" : [self releaseDict]
                                       } mutableCopy];
    
    NSString *roleTitle = [RUUserInfoManager currentUserRole][@"title"];
    NSString *campusTitle = [RUUserInfoManager currentCampus][@"title"];
    
    if (roleTitle) baseEvent[@"role"] = roleTitle;
    if (campusTitle) baseEvent[@"campus"] = campusTitle;
    
    return baseEvent;
}

-(NSDictionary *)platform{
    UIDevice *device = [UIDevice currentDevice];
    return @{
             @"id" : device.identifierForVendor.UUIDString,
             @"os" : device.systemName,
             @"model" : device.model,
             @"tablet" : @(iPad()),
             @"version" : device.systemVersion
             };
}

-(NSDictionary *)releaseDict{
    return @{
             @"beta" : @(BETA)
             };
}

-(void)queueAnalyticsEvents:(NSArray *)events{
    @synchronized (self) {
        [self.queue addObjectsFromArray:events];
        if (self.queue.count < 10) {
            [self resetFlushTimer];
        } else {
            [self flushQueue];
        }
    }
}

-(void)queueAnalyticsEvent:(NSDictionary *)event{
    [self queueAnalyticsEvents:@[event]];
}

-(void)resetFlushTimer{
    [self.flushTimer invalidate];
    self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(flushQueue) userInfo:nil repeats:NO];
}

-(void)flushQueue{
    @synchronized(self) {
        [self.flushTimer invalidate];
        [self postAnalyticsEvents:self.queue];
        [self.queue removeAllObjects];
    }
}

-(void)postAnalyticsEvents:(NSArray *)events{
    NSString *url = @"analytics.php";
    
    if (BETA) {
        url = @"http://sauron.rutgers.edu/~jamchamb/analytics.php";
    }
    
    [[RUNetworkManager sessionManager] POST:url parameters:@{@"payload" : [self payloadStringForEvents:events]} success:nil failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self queueAnalyticsEvents:events];
    }];
}

-(NSString *)payloadStringForEvents:(NSArray *)events{
    NSData *data = [NSJSONSerialization dataWithJSONObject:events options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end

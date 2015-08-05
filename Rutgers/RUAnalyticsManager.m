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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushQueue) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushQueue) name:UIApplicationWillTerminateNotification object:nil];
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
    self.firstLaunch = NO;

    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"fresh_launch"
                                      }];
    [self queueAnalyticsEvent:event];
}

-(void)queueEventForApplicationLaunch{
    if (self.firstLaunch) {
        [self queueEventForFirstLaunch];
    }
    
    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"launch"
                                      }];
    [self queueAnalyticsEvent:event];
}

-(BOOL)shouldIgnoreError:(NSError *)error{
    static NSDictionary *ignoredErrorsByDomain;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignoredErrorsByDomain = @{
                                  NSURLErrorDomain : @[@-1009]
                                  };
    });
    
    NSArray *ignoredErrorsForDomain = ignoredErrorsByDomain[error.domain];
    return [ignoredErrorsForDomain containsObject:@(error.code)];
}

-(void)queueEventForError:(NSError *)error{
    if ([self shouldIgnoreError:error]) return;
    
    NSMutableDictionary *event = [self baseEvent];
    
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    
    [error.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
            errorDict[key] = value;
        }
    }];
    
    [event addEntriesFromDictionary:@{
                                      @"type" : @"error",
                                      @"error" : errorDict
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

#warning incomplete
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
             @"beta" : @(BETA),
             @"version" : gittag,
             @"api" : api
             };
}

-(void)queueAnalyticsEvents:(NSArray *)events{
    @synchronized (self) {
        [self.queue addObjectsFromArray:events];
        [self resetFlushTimer];
    }
}

-(void)queueAnalyticsEvent:(NSDictionary *)event{
    [self queueAnalyticsEvents:@[event]];
}

-(void)resetFlushTimer{
    @synchronized(self) {
        [self.flushTimer invalidate];
        self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(flushQueue) userInfo:nil repeats:NO];
    }
}

-(void)flushQueue{
    @synchronized(self) {
        [self.flushTimer invalidate];
        [self postAnalyticsEvents:[self.queue copy]];
        [self.queue removeAllObjects];
    }
}

-(void)postAnalyticsEvents:(NSArray *)events{
    if (!events.count) return;
    
    UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    [[RUNetworkManager sessionManager] POST:@"analytics.php" parameters:@{@"payload" : [self jsonStringForObject:events]} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Analytics sent successfully");
        [[UIApplication sharedApplication] endBackgroundTask:identifier];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error sending analytics, retrying");
        [[UIApplication sharedApplication] endBackgroundTask:identifier];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            [self queueAnalyticsEvents:events];
        }
    }];
}

-(NSString *)jsonStringForObject:(id)object{
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end

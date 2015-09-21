//
//  RUAnalyticsManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUAnalyticsManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"
#import "RUUserInfoManager.h"
#import "RUDefines.h"

@interface RUAnalyticsManager ()
@property NSMutableArray *queue;
@property NSTimer *flushTimer;

//This property is backed by persistent storage
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
        
        //Register for notifications to flush before the application dies
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushQueue) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushQueue) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

//The following key and methods define how to persistently store if this is the first launch
static NSString *const kAnalyticsManagerFirstLaunchKey = @"kAnalyticsManagerFirstLaunchKey";

-(BOOL)firstLaunch{
    //First we register the default value of yes
    //What this does is ensure that if there is an absence of a value for this key, we will get yes by default
    //As soon as a value is set, that will be read instead of the "default" value.
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kAnalyticsManagerFirstLaunchKey : @(YES)}];
    
    //Get either the value stored, or the default value
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAnalyticsManagerFirstLaunchKey];
}

-(void)setFirstLaunch:(BOOL)firstLaunch{
    [[NSUserDefaults standardUserDefaults] setBool:firstLaunch forKey:kAnalyticsManagerFirstLaunchKey];
}


//This method is internal and not listed in the public header
-(void)queueEventForFirstLaunch{
    //Call the above setter
    self.firstLaunch = NO;

    NSMutableDictionary *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"type" : @"fresh_launch"
                                      }];
    [self queueAnalyticsEvent:event];
}

//This is the public method called each time the app starts
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

//This method contains a mapping between error domains, and an array of codes within the domain to ignore
-(BOOL)shouldIgnoreError:(NSError *)error{
    static NSDictionary *ignoredErrorsByDomain;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignoredErrorsByDomain = @{
                                  NSURLErrorDomain : @[@-1009] //NSURLErrorNotConnectedToInternet
                                  };
    });
    
    NSArray *ignoredErrorsForDomain = ignoredErrorsByDomain[error.domain];
    return [ignoredErrorsForDomain containsObject:@(error.code)];
}

-(void)queueEventForError:(NSError *)error{
    if ([self shouldIgnoreError:error]) return;
    
    NSMutableDictionary *event = [self baseEvent];
    
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    
    //Loop through the error info for any strings that might be useful
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
                                       @"date" : [NSString stringWithFormat:@"@%ld",((long)[NSDate date].timeIntervalSince1970)], //Unix timestamp
                                       @"platform" : [self platform], //Device info
                                       @"release" : [self releaseDict] //Version info
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
             @"beta" : @(isBeta()),
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
        self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(flushQueue) userInfo:nil repeats:NO];
    }
}

-(void)flushQueue{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        @synchronized(self) {
            [self.flushTimer invalidate];
            [self postAnalyticsEvents:[self.queue copy]];
            [self.queue removeAllObjects];
        }
    });
}

-(void)postAnalyticsEvents:(NSArray *)events{
    if (!events.count) return;
    
    [[RUNetworkManager backgroundSessionManager] POST:@"analytics.php" parameters:@{@"payload" : [self jsonStringForObject:events]} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Analytics sent successfully");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            NSLog(@"Error sending analytics, retrying");
            [self queueAnalyticsEvents:events];
        }
    }];
}

-(NSString *)jsonStringForObject:(id)object{
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end

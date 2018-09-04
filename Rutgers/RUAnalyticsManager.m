//
//  RUAnalyticsManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

/*
   
    Descript : 
        Talks back to the server with the data about the usage by the app
 
 */

#import "RUAnalyticsManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"
#import "RUUserInfoManager.h"
#import "RUDefines.h"

@interface RUAnalyticsManager ()
@property NSMutableArray *queue;   // Used to keep a queue about the event that take place in the app : Like which channel is being opened etc.
@property NSTimer *flushTimer;      // Maintains time interval for which to collect user information and at the end of the time, send the queue contents to postAnalytics

//This property is backed by persistent storage
@property BOOL firstLaunch;
@end

@implementation RUAnalyticsManager
+(instancetype)sharedManager
{
    static RUAnalyticsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
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

-(BOOL)firstLaunch
{
    //First we register the default value of yes
    //What this does is ensure that if there is an absence of a value for this key, we will get yes by default
    //As soon as a value is set, that will be read instead of the "default" value.
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kAnalyticsManagerFirstLaunchKey : @(YES)}];
    
    //Get either the value stored, or the default value
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAnalyticsManagerFirstLaunchKey];
}

-(void)setFirstLaunch:(BOOL)firstLaunch
{
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


/*
    add each channel that is opened into base Event
    // Not sure if this is done for each channel , or whether it is done only during start up . Make Sure ... 
    Descript : 
        Seems to add information about open channel to base event and add it to the queue
        and the queue is posted to internet as json after a specific time interval
 
    // Should each event be send to the servers ?
 
    
    Do the enque in the background
 
 */
-(void)queueEventForChannelOpen:(NSDictionary *)channel
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
    ^{
        NSString *channelHandle = [channel channelHandle];
        if (!channelHandle) return;
        NSMutableDictionary *event = [self baseEvent];
        [event addEntriesFromDictionary:@{
                                          @"type" : @"channel",
                                          @"handle" : channelHandle
                                          }];
        [self queueAnalyticsEvent:event];
    });
    
   
}

-(void)queueEventForUserInteraction:(NSDictionary *)userInteraction{
    return;
    /*
    NSMutableDictionary *event = [self baseEvent];
    event[@"userInteraction"] = userInteraction;
    [self queueAnalyticsEvent:event];
    NSLog(@"%@",event);*/
}

/*
    Dict with some basic information about the app and its user.
 */
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

/*
    Holds information about the platfrom and realease Data for reporting in the analytics
 */

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

/*
    Queue mulitple events using mutex lock
    Add each event into the queue
 */
-(void)queueAnalyticsEvents:(NSArray *)events{
    @synchronized (self) {
        [self.queue addObjectsFromArray:events];    // add the array to the queue
        [self resetFlushTimer];
    }
}

-(void)queueAnalyticsEvent:(NSDictionary *)event{
    [self queueAnalyticsEvents:@[event]];
}

// Reset the timer to set up the next interval over which to send the event...
-(void)resetFlushTimer{
    @synchronized(self) {
        [self.flushTimer invalidate];
        self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(flushQueue) userInfo:nil repeats:NO];
    }
}

-(void)flushQueue{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @synchronized(self) {
            [self.flushTimer invalidate];
            [self postAnalyticsEvents:[self.queue copy]];
            [self.queue removeAllObjects];
        }
    });
}

-(void)saveException:(NSException *)exception {
    NSMutableDictionary* event = [self baseEvent];
    [event addEntriesFromDictionary: @{
        @"type": @"exception",
        @"exception_name": [exception name],
        @"exception_reason": [exception reason],
        @"stack_trace": [[exception callStackSymbols] componentsJoinedByString:@"\n"]
    }];
    [self queueAnalyticsEvent:event];

    // If we have an old crash report that didn't get sent, append it to the
    // current queue
    NSArray* item = [[NSUserDefaults standardUserDefaults] objectForKey:CrashKey];
    if (item != nil) {
        [self.queue addObjectsFromArray:item];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CrashKey];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[self.queue copy] forKey:CrashKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/*
    Send the event over the network , if failure stores it for next attempt at sending
    
    LOOK AT :   
        analytics.php
 
    Data send as Json
 */
-(void)postAnalyticsEvents:(NSArray *)events{
    if (!events.count) return;
    // Convert the event array into Json
    AFHTTPRequestSerializer *oldSerializer = [RUNetworkManager backgroundSessionManager].requestSerializer;
    [RUNetworkManager backgroundSessionManager].requestSerializer = [[AFJSONRequestSerializer alloc] init];
    [[RUNetworkManager backgroundSessionManager] POST:@"analytics.php" parameters:events progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Analytics sent successfully");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            NSLog(@"Error sending analytics, retrying");
            NSLog(@"ERROR : %@", error);
            [self queueAnalyticsEvents:events];
        }
    }];
    [RUNetworkManager backgroundSessionManager].requestSerializer = oldSerializer;
}

// Creates the json serialization
-(NSString *)jsonStringForObject:(id)object{
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end

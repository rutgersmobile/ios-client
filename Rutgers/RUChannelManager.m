//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSDictionary+Channel.h"
#import "RUDataLoadingManager_Private.h"
#import "RUNetworkManager.h"
#import "RUChannelManager.h"
#import "RUChannelProtocol.h"
#import "RUAnalyticsManager.h"

NSString *const ChannelManagerJsonFileName = @"ordered_content";
NSString *const ChannelManagerDidUpdateChannelsKey = @"ChannelManagerDidUpdateChannelsKey";

#define CHANNEL_CACHE_TIME 60*60*24*1

@interface RUChannelManager ()
@property dispatch_group_t loadingGroup;

@property BOOL loading;
@property BOOL finishedLoading;
@property NSError *loadingError;
@end

@implementation RUChannelManager

+(RUChannelManager *)sharedInstance{
    static RUChannelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RUChannelManager alloc] init];
    });
    return manager;
}

#pragma mark - Channel Information Methods
@synthesize otherChannels = _otherChannels;
-(NSArray *)otherChannels{
    if (!_otherChannels) {
        _otherChannels = @[
                           @{@"handle" : @"options",
                             @"title" : @"Options",
                             @"view" : @"options",
                             @"icon" : @"gear"}
                           ];
    }
    return _otherChannels;
}

@synthesize contentChannels = _contentChannels;
-(NSArray *)contentChannels{
    @synchronized(self) {
        if (!_contentChannels) {
            NSDate *latestDate;
            NSArray *paths = @[[self documentPath],[self bundlePath]];
            
            for (NSString *path in paths) {
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
                NSDate *date = [attributes fileModificationDate];
                
                if (!latestDate || [date compare:latestDate] == NSOrderedDescending) {
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    if (data) {
                        NSArray *channels = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        if (channels.count) {
                            latestDate = date;
                            _contentChannels = channels;
                        }
                    }
                }
            }
        
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            if ([self needsLoad]) {
                [self load];
            }
        });
        return _contentChannels;
    }
}


-(NSDictionary *)channelWithHandle:(NSString *)handle{
    for (NSDictionary *channel in self.contentChannels) {
        if ([[channel channelHandle] isEqualToString:handle]) {
            return channel;
        }
    }
    for (NSDictionary *channel in self.otherChannels) {
        if ([[channel channelHandle] isEqualToString:handle]) {
            return channel;
        }
    }
    return nil;
}

-(void)setContentChannels:(NSArray *)allChannels{
    if (!allChannels.count) return;
    
    @synchronized(self) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:allChannels options:0 error:nil];
        if (data) [data writeToFile:[self documentPath] atomically:YES];
        
        if ([_contentChannels isEqual:allChannels]) return;
        
        _contentChannels = allChannels;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ChannelManagerDidUpdateChannelsKey object:self];
        });
    }
}

#pragma mark Channel manager loading
-(NSString *)documentPath{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [documentsDir stringByAppendingPathComponent:[ChannelManagerJsonFileName stringByAppendingPathExtension:@"json"]];
}

-(NSString *)bundlePath{
    return [[NSBundle mainBundle] pathForResource:ChannelManagerJsonFileName ofType:@"json"];
}

-(BOOL)needsLoad{
    if (![super needsLoad]) return NO;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self documentPath] error:nil];
    NSDate *date = [attributes fileModificationDate];
    if (!date) return YES;
    
    return ([date compare:[NSDate dateWithTimeIntervalSinceNow:-CHANNEL_CACHE_TIME]] == NSOrderedAscending);
}

-(void)load{
    [self willBeginLoad];
    [[RUNetworkManager sessionManager] GET:[ChannelManagerJsonFileName stringByAppendingPathExtension:@"json"] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.contentChannels = responseObject;
            [self didEndLoad:YES withError:nil];
        } else {
            [self didEndLoad:NO withError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self didEndLoad:NO withError:error];
    }];
}

-(Class)classForViewTag:(NSString *)viewTag{
    NSString *className = [self viewTagsToClassNameMapping][viewTag];
    return NSClassFromString(className);
}

-(NSMutableDictionary *)viewTagsToClassNameMapping{
    static NSMutableDictionary *viewTagsToClassNameMapping = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        viewTagsToClassNameMapping = [NSMutableDictionary dictionary];
    });
    return viewTagsToClassNameMapping;
}

-(void)registerClass:(Class)class{
    if (![class conformsToProtocol:@protocol(RUChannelProtocol)]) return;
    NSString *handle = [class performSelector:@selector(channelHandle)];
    [self viewTagsToClassNameMapping][handle] = NSStringFromClass(class);
}

-(UIViewController <RUChannelProtocol>*)viewControllerForChannel:(NSDictionary *)channel{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[RUAnalyticsManager sharedManager] queueEventForChannelOpen:channel];
    });
    
    NSString *view = channel[@"view"];
    if (!view) view = [self defaultViewForChannel:channel];
    Class class = [self classForViewTag:view];
    
    if (![class conformsToProtocol:@protocol(RUChannelProtocol)]) [NSException raise:@"Invalid View" format:@"No way to handle view type %@",view];
    
    UIViewController <RUChannelProtocol>*vc = [class channelWithConfiguration:channel];
    vc.title = [channel channelTitle];
    return vc;

}

-(NSArray *)viewControllersForURL:(NSURL *)url destinationTitle:(NSString *)destinationTitle{
    NSMutableArray *components = [url.absoluteString.pathComponents mutableCopy];
    [components removeObjectAtIndex:0];
   
    NSString *handle = components.firstObject;
    [components removeObjectAtIndex:0];
    
    return [(id)[self classForViewTag:handle] performSelector:@selector(viewControllersWithPathComponents:destinationTitle:) withObject:components withObject:destinationTitle];
}

-(NSString *)defaultViewForChannel:(NSDictionary *)channel{
    NSArray *children = channel[@"children"];
    for (NSDictionary *child in children) {
        if (child[@"answer"]) return @"faqview";
    }
    return @"dtable";
}

static NSString *const ChannelManagerLastChannelKey = @"ChannelManagerLastChannelKey";

-(NSDictionary *)lastChannel{
    NSDictionary *lastChannel = [[NSUserDefaults standardUserDefaults] dictionaryForKey:ChannelManagerLastChannelKey];
    if (![self.contentChannels containsObject:lastChannel]) lastChannel = nil;
    if (!lastChannel) lastChannel = @{@"view" : @"splash", @"title" : @"Welcome!"};
    return lastChannel;
}

-(void)setLastChannel:(NSDictionary *)lastChannel{
    if ([self.contentChannels containsObject:lastChannel]) {
        [[NSUserDefaults standardUserDefaults] setObject:lastChannel forKey:ChannelManagerLastChannelKey];
    }
}
@end

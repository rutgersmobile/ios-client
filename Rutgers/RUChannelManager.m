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

@synthesize allChannels = _allChannels;
-(NSArray *)allChannels{
    @synchronized(self) {
        if (!_allChannels) {
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
                            _allChannels = channels;
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
        return _allChannels;
    }
}


-(NSDictionary *)channelWithHandle:(NSString *)handle{
    for (NSDictionary *channel in self.allChannels) {
        if ([[channel channelHandle] isEqualToString:handle]) {
            return channel;
        }
    }
    return nil;
}

-(void)setAllChannels:(NSArray *)allChannels{
    if (!allChannels.count) return;
    
    @synchronized(self) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:allChannels options:0 error:nil];
        if (data) [data writeToFile:[self documentPath] atomically:YES];
        
        if ([_allChannels isEqual:allChannels]) return;
        
        _allChannels = allChannels;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ChannelManagerDidUpdateChannelsKey object:self];
        });
    }
}

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
            self.allChannels = responseObject;
            [self didEndLoad:YES withError:nil];
        } else {
            [self didEndLoad:NO withError:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self didEndLoad:NO withError:error];
    }];
}

-(Class)classForViewTag:(NSString *)viewTag{
    static NSDictionary *viewTagsToClassNameMapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewTagsToClassNameMapping = @{
                                       @"bus" : @"RUBusViewController",
                                       @"faqview" : @"FAQViewController",
                                       @"dtable" : @"DynamicTableViewController",
                                       @"food" : @"RUFoodViewController",
                                       @"places" : @"RUPlacesViewController",
                                       @"ruinfo" : @"RUInfoTableViewController",
                                       @"soc" : @"RUSOCViewController",
                                       @"athletics" : @"RUSportsViewController",
                                       @"emergency" : @"RUEmergencyViewController",
                                       @"Reader" :  @"RUReaderViewController",
                                       @"recreation" : @"RURecreationViewController",
                                       @"www" : @"RUWebViewController",
                                       //@"www" : @"RUWebViewContainerViewController",
                                       @"text" : @"RUTextViewController",
                                       @"feedback" : @"RUFeedbackViewController",
                                       @"options" : @"RUOptionsViewController",
                                       @"splash" : @"RUSplashViewController",
                                       @"maps" : @"RUMapsChannelViewController"
                                       };
    });
    return NSClassFromString(viewTagsToClassNameMapping[viewTag]);
}

-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[RUAnalyticsManager sharedManager] queueEventForChannelOpen:channel];
    });
    
    NSString *view = channel[@"view"];
    if (!view) view = [self defaultViewForChannel:channel];
    Class class = [self classForViewTag:view];
    
    if (![class conformsToProtocol:@protocol(RUChannelProtocol)]) [NSException raise:@"Invalid View" format:@"No way to handle view type %@",view];
    UIViewController *vc = [class channelWithConfiguration:channel];
    vc.title = [channel channelTitle];
    return vc;

}

-(NSArray *)viewControllersForURL:(NSURL *)url{
    return @[[self viewControllerForChannel:[self channelWithHandle:url.host]]];
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
    if (![self.allChannels containsObject:lastChannel]) lastChannel = nil;
    if (!lastChannel) lastChannel = @{@"view" : @"splash", @"title" : @"Welcome!"};
    return lastChannel;
}

-(void)setLastChannel:(NSDictionary *)lastChannel{
    if ([self.allChannels containsObject:lastChannel]) {
        [[NSUserDefaults standardUserDefaults] setObject:lastChannel forKey:ChannelManagerLastChannelKey];
    }
}
@end

//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSDictionary+Channel.h"
#import "RUDataLoadingManager_Private.h"

NSString *const ChannelManagerJsonFileName = @"ordered_content";
NSString *const ChannelManagerDidUpdateChannelsKey = @"ChannelManagerDidUpdateChannelsKey";

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
                        if (channels) {
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

-(void)setAllChannels:(NSArray *)allChannels{
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
    NSString *pathForFile = [documentsDir stringByAppendingPathComponent:[ChannelManagerJsonFileName stringByAppendingPathExtension:@"json"]];
    return pathForFile;
}

-(NSString *)bundlePath{
    return [[NSBundle mainBundle] pathForResource:ChannelManagerJsonFileName ofType:@"json"];
}


-(BOOL)needsLoad{
    if (![super needsLoad]) return NO;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self documentPath] error:nil];
    NSDate *date = [attributes fileModificationDate];
    if (!date) return YES;
    
    return YES;//([date compare:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*3]] == NSOrderedAscending);
}

-(void)load{
    [self willBeginLoad];
    [[RUNetworkManager sessionManager] GET:@"ordered_content.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.allChannels = responseObject;
        }
        [self didEndLoad:YES withError:nil];
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
                                       @"text" : @"RUTextViewController",
                                       @"feedback" : @"RUFeedbackViewController",
                                       @"options" : @"RUOptionsViewController",
                                       @"splash" : @"RUSplashViewController"
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
    
    if (!class) [NSException raise:@"Invalid View" format:@"No way to handle view type %@",view];
    
    UIViewController * vc;
    if ([class respondsToSelector:@selector(newWithChannel:)]) {
        vc = [class newWithChannel:channel];
    } else {
        NSLog(@"%@ does not implement RUChannelProtocol, \n%@",NSStringFromClass(class),channel);
        vc = [class new];
    }
    vc.title = [channel channelTitle];
    return vc;
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

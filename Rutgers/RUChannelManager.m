//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSDictionary+Channel.h"

NSString *const ChannelManagerJsonFileName = @"ordered_content";
NSString *const ChannelManagerDidUpdateChannelsKey = @"ChannelManagerDidUpdateChannelsKey";

@interface RUChannelManager ()
@property (readonly) NSMutableDictionary *channelsByHandle;

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

-(instancetype)init{
    self = [super init];
    if (self) {
        self.loadingGroup = dispatch_group_create();
        if ([self orderedContentNeedsLoad]) {
            [self loadOrderedContent];
        }
    }
    return self;
}

@synthesize allChannels = _allChannels;
-(NSArray *)allChannels{
    @synchronized(self) {
        if (!_allChannels) {
            NSArray *paths = @[[self documentPath],[self bundlePath]];
            for (NSString *path in paths) {
                NSData *data = [NSData dataWithContentsOfFile:path];
                if (data) {
                    NSError *error;
                    NSArray *channels = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                    if (channels && !error) {
                        _allChannels = channels;
                        break;
                    }
                }
            }
        }
        return _allChannels;
    }
}

-(void)setAllChannels:(NSArray *)allChannels{
    @synchronized(self) {
        
        if ([_allChannels isEqual:allChannels]) return;
        
        _allChannels = allChannels;
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:allChannels options:0 error:nil];
        
        if (data) {
            [data writeToFile:[self documentPath] atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ChannelManagerDidUpdateChannelsKey object:self];
            });
        }
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

-(BOOL)orderedContentNeedsLoad{
    return !(self.loading || self.finishedLoading) && [self cacheNeedsReload];
}

-(BOOL)cacheNeedsReload{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self documentPath] error:nil];
    NSDate *date = [attributes fileModificationDate];
    BOOL needsReload = ([date compare:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*3]] == NSOrderedAscending);
    return needsReload;
}

-(void)performWhenWebChannelsLoaded:(void (^)(NSError *error))handler{
    if ([self orderedContentNeedsLoad]) {
        [self loadOrderedContent];
    }
    dispatch_group_notify(self.loadingGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        handler(self.loadingError);
    });
}


-(void)loadOrderedContent{
    dispatch_group_enter(self.loadingGroup);
    
    self.loading = YES;
    self.finishedLoading = NO;
    self.loadingError = nil;
    
    #warning change this url
    [[RUNetworkManager sessionManager] GET:@"https://nstanlee.rutgers.edu/~rfranknj/mobile/1/ordered_content.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.allChannels = responseObject;
        }
        
        self.loading = NO;
        self.finishedLoading = YES;
        self.loadingError = nil;
        
        dispatch_group_leave(self.loadingGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        self.loading = NO;
        self.finishedLoading = NO;
        self.loadingError = error;
        
        dispatch_group_leave(self.loadingGroup);
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
    
    if (class) {
        UIViewController * vc;
        if ([class respondsToSelector:@selector(newWithOptions:)]) {
            vc = [class newWithOptions:channel];
        } else {
            NSLog(@"%@ does not implement RUChannelProtocol, \n%@",NSStringFromClass(class),channel);
            vc = [class new];
        }
        NSString *title = [channel channelTitle];
        vc.title = title;
        
        return vc;
    } else {
        NSLog(@"No way to handle view type %@, \n%@",view,channel);
    }
    return nil;
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
    if (lastChannel && ![lastChannel channelIsWebLink] && !self.channelsByHandle[[lastChannel channelHandle]]) lastChannel = nil;
    if (!lastChannel) lastChannel = @{@"view" : @"splash", @"title" : @"Welcome!"};
    return lastChannel;
}

-(void)setLastChannel:(NSDictionary *)lastChannel{
    [[NSUserDefaults standardUserDefaults] setObject:lastChannel forKey:ChannelManagerLastChannelKey];
}
@end

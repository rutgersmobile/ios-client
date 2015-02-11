//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NSDictionary+Channel.h"

@interface RUChannelManager ()
@property (readonly) NSMutableDictionary *channelsByHandle;

@property dispatch_group_t webChannelsGroup;
@property NSArray *webChannels;

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
        self.webChannelsGroup = dispatch_group_create();
        [self loadWebChannels];
    }
    return self;
}

@synthesize nativeChannels = _nativeChannels;
-(NSArray *)nativeChannels{
    @synchronized(self) {
        if (!_nativeChannels) {
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Channels" ofType:@"json"]];
            _nativeChannels =  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        return _nativeChannels;
    }
}

@synthesize channelsByHandle = _channelsByHandle;
-(NSMutableDictionary *)channelsByHandle{
    @synchronized(self) {
        if (!_channelsByHandle) {
            NSMutableDictionary *channelsByTag = [NSMutableDictionary dictionary];
            for (NSDictionary *channel in self.nativeChannels) {
                NSString *handle = [channel channelHandle];
                if (handle) channelsByTag[handle] = channel;
            }
            _channelsByHandle = channelsByTag;
        }
        return _channelsByHandle;
    }
}

-(void)webLinksWithCompletion:(void (^)(NSArray *, NSError *))completion{
    [self performWhenWebChannelsLoaded:^(NSError *error) {
        completion(self.webChannels,error);
    }];
}

-(BOOL)webChannelsNeedLoad{
    return !(self.loading || self.finishedLoading);
}

-(void)performWhenWebChannelsLoaded:(void (^)(NSError *error))handler{
    if ([self webChannelsNeedLoad]) {
        [self loadWebChannels];
    }
    dispatch_group_notify(self.webChannelsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        handler(self.loadingError);
    });
}


-(void)loadWebChannels{
    dispatch_group_enter(self.webChannelsGroup);
    
    self.loading = YES;
    self.finishedLoading = NO;
    self.loadingError = nil;
    
    [[RUNetworkManager sessionManager] GET:@"shortcuts.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.webChannels = [self filterWebChannels:responseObject];
        }
        
        self.loading = NO;
        self.finishedLoading = YES;
        self.loadingError = nil;
        
        dispatch_group_leave(self.webChannelsGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        self.loading = NO;
        self.finishedLoading = NO;
        self.loadingError = error;
        
        dispatch_group_leave(self.webChannelsGroup);
    }];
}

-(NSArray *)filterWebChannels:(NSArray *)webChannels{
    NSMutableArray *filteredWebChannels = [NSMutableArray array];
    for (NSDictionary *channel in webChannels) {
        NSString *handle = [channel channelHandle];
        if (!self.channelsByHandle[handle]) {
            self.channelsByHandle[handle] = channel;
            NSMutableDictionary *modifiedWebChannel = [channel mutableCopy];
            modifiedWebChannel[@"view"] = @"www";
            modifiedWebChannel[@"weblink"] = @YES;
            [filteredWebChannels addObject:modifiedWebChannel];
        }
    }
    return filteredWebChannels;
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
    [[RUAnalyticsManager sharedManager] queueEventForChannelOpen:channel];
    NSString *view = channel[@"view"];
    if (!view) view = [self defaultViewForChannel:channel];
    
    Class class = [self classForViewTag:view];
    
    if (class) {
        UIViewController * vc;
        if ([class respondsToSelector:@selector(channelWithConfiguration:)]) {
            vc = [class channelWithConfiguration:channel];
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

-(NSArray *)allChannels{
    return [self.nativeChannels arrayByAddingObjectsFromArray:self.webChannels];
}

static NSString *const kChannelManagerLastChannelKey = @"kChannelManagerLastChannelKey";

-(NSDictionary *)lastChannel{
    NSDictionary *lastChannel = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kChannelManagerLastChannelKey];
    if (lastChannel && ![lastChannel channelIsWebLink] && !self.channelsByHandle[[lastChannel channelHandle]]) lastChannel = nil;
    if (!lastChannel) lastChannel = @{@"view" : @"splash"};
    return lastChannel;
}

-(void)setLastChannel:(NSDictionary *)lastChannel{
    [[NSUserDefaults standardUserDefaults] setObject:lastChannel forKey:kChannelManagerLastChannelKey];
}
@end

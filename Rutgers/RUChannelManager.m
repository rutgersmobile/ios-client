//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


@interface RUChannelManager ()
@property (readonly) NSSet *nativeChannelHandles;
@property dispatch_group_t webLinksGroup;
@property NSArray *webChannels;
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
        self.webLinksGroup = dispatch_group_create();
        [self getWebChannels];
    }
    return self;
}

@synthesize nativeChannels = _nativeChannels;
-(NSArray *)nativeChannels{
    @synchronized(self) {
        if (!_nativeChannels) {
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Channels" ofType:@"json"]];
            _nativeChannels =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        }
        return _nativeChannels;
    }
}

@synthesize nativeChannelHandles = _nativeChannelHandles;
-(NSSet *)nativeChannelHandles{
    @synchronized(self) {
        if (!_nativeChannelHandles) _nativeChannelHandles = [self.nativeChannels valueForKey:@"handle"];
        return _nativeChannelHandles;
    }
}

-(void)webLinksWithCompletion:(void (^)(NSArray *))completion{
    if (!self.webChannels) [self getWebChannels];
    dispatch_group_notify(self.webLinksGroup, dispatch_get_main_queue(), ^{
        completion(self.webChannels);
    });
}

-(void)getWebChannels{
    dispatch_group_enter(self.webLinksGroup);
    [[RUNetworkManager sessionManager] GET:@"shortcuts.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.webChannels = [self filterWebChannels:responseObject];
        }
        dispatch_group_leave(self.webLinksGroup);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.webChannels) [self getWebChannels];
            dispatch_group_leave(self.webLinksGroup);
        });
    }];
}

-(NSArray *)filterWebChannels:(NSArray *)webChannels{
    NSMutableArray *filteredWebChannels = [NSMutableArray array];
    for (NSDictionary *channel in webChannels) {
        NSString *handle = [channel channelHandle];
        if (![self.nativeChannelHandles containsObject:handle]) {
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
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kChannelManagerLastChannelKey];
}

-(void)setLastChannel:(NSDictionary *)lastChannel{
    [[NSUserDefaults standardUserDefaults] setObject:lastChannel forKey:kChannelManagerLastChannelKey];
}
@end

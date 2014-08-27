//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


@interface RUChannelManager ()
@property (readonly) NSSet *nativeChannelHandles;
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
    [[RUNetworkManager sessionManager] GET:@"shortcuts.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.webChannels = [self filterWebChannels:responseObject];
            completion(self.webChannels);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self webLinksWithCompletion:completion];
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
                                       @"options" : @"RUOptionsViewController"
                                       };
    });
    return NSClassFromString(viewTagsToClassNameMapping[viewTag]);
}

-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel{
    [RUAnalyticsManager postAnalyticsForChannelOpen:channel];
    NSString *view = channel[@"view"];
    if (!view) view = [self defaultViewForChannel:channel];
    
    Class class = [self classForViewTag:view];
    
    if (class && [class respondsToSelector:@selector(channelWithConfiguration:)]) {
        UIViewController * vc = [class channelWithConfiguration:channel];
        NSString *title = [channel channelTitle];
        vc.title = title;
        return vc;
    } else {
        if (class) {
            NSLog(@"%@ does not implement RUChannelProtocol, \n%@",NSStringFromClass(class),channel);
        } else {
            NSLog(@"No way to handle view type %@, \n%@",view,channel);
        }
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

@end

//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//
#import "RUChannelManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"

#import "RUChannelProtocol.h"

@interface RUChannelManager ()
@property NSArray *channelTags;
@property NSMutableDictionary *channels;
@end

@implementation RUChannelManager
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.channels = [NSMutableDictionary dictionary];
    }
    return self;
}

+(RUChannelManager *)sharedInstance{
    static RUChannelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RUChannelManager alloc] init];
    });
    return manager;
}

-(NSArray *)loadChannels{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Channels" ofType:@"json"]];
    NSError *error;
    if (error && !data) {
    } else {
        NSArray *channels = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        for (NSDictionary *channel in channels) {
            NSString *handle = [channel handle];
            self.channels[handle] = channel;
        }
        return channels;
    }
    return nil;
}

-(void)loadWebLinksWithCompletion:(void(^)(NSArray *webLinks))completion{
    [[RUNetworkManager jsonSessionManager] GET:@"shortcuts.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *webChannels = responseObject;
            NSMutableArray *filteredWebChannels = [NSMutableArray array];
            for (NSDictionary *channel in webChannels) {
                NSString *handle = [channel handle];
                if (!self.channels[handle]) {
                    self.channels[handle] = channel;
                    [filteredWebChannels addObject:channel];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(filteredWebChannels);
            });
        } else {

        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadWebLinksWithCompletion:completion];
        });
    }];
}

-(Class)classForViewTag:(NSString *)viewTag{
    static NSDictionary *viewTagsToClassNameMapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewTagsToClassNameMapping = @{
                                       @"bus" : @"RUBusViewController",
                                       @"newbus" : @"RUNewBusViewController",
                                       @"dtable" : @"DynamicCollectionViewController",
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
                                       @"feedback" : @"RUFeedbackViewController"
                                       };
    });
    return NSClassFromString(viewTagsToClassNameMapping[viewTag]);
}

-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel{
    NSString *view = channel[@"view"];
    if (!view) view = @"www";
    Class class = [self classForViewTag:view];
    if (class && [class respondsToSelector:@selector(channelWithConfiguration:)]) {
        UIViewController * vc = [class channelWithConfiguration:channel];
        NSString *title = [channel titleForChannel];
        vc.title = title;
        return vc;
    } else {
        NSLog(@"No way to handle view type %@, \n%@",view,channel);
    }
    return nil;
}


@end

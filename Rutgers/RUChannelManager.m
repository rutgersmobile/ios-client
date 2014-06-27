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

#import "RUComponentProtocol.h"

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
            webChannels = [webChannels filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                NSString *handle = [evaluatedObject handle];
                if (self.channels[handle]) {
                    return false;
                } else {
                    self.channels[handle] = evaluatedObject;
                    return true;
                }
            }]];
            completion(webChannels);
        } else {

        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadWebLinksWithCompletion:completion];
        });
    }];
}

-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel{
    NSString *view = channel[@"view"];
    if (!view) view = @"www";
    if ([view isEqualToString:@"dtable"]) view = @"DynamicCollectionView";
    Class class = NSClassFromString(view);
    if (class && [class respondsToSelector:@selector(componentForChannel:)]) {
        UIViewController * vc = [class componentForChannel:channel];
        NSString *title = [channel titleForChannel];
        vc.title = title;
        vc.tabBarItem.title = title;
        vc.tabBarItem.image = [channel iconForChannel];
        return vc;
    } else {
        NSLog(@"No way to handle view type %@, \n%@",view,channel);
    }
    return nil;
}


@end

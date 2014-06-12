//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//
#import "RUChannelManager.h"
#import "RUNetworkManager.h"

/*
#import "Reader.h"
#import "www.h"
#import "RUInfoTableViewController.h"
#import "dtable.h"
#import "RUBusViewController.h"
#import "RUPlacesViewController.h"
#import "RUFoodViewController.h"
#import "RUMapsViewController.h"
#import "RUMenuController.h"
*/
#import "RUComponentProtocol.h"

@interface RUChannelManager ()
@property NSArray *webChannels;
@property NSArray *channels;
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

-(NSArray *)loadChannels{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Channels" ofType:@"json"]];
    NSError *error;
    if (error && !data) {
    } else {
        self.channels = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    }
    return self.channels;
}
-(void)loadWebLinksWithCompletion:(void(^)(NSArray *webLinks))completion{
    [[RUNetworkManager jsonSessionManager] GET:@"shortcuts.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.webChannels = responseObject;
            completion(responseObject);
        } else {
            [self loadWebLinksWithCompletion:completion];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self loadWebLinksWithCompletion:completion];
    }];
}

-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel{
    NSString *view = channel[@"view"];
    //everthing from shortcuts.txt will get a view of www
    if ([self.webChannels containsObject:channel]) view = @"www";
    if ([view isEqualToString:@"dtable"]) view = @"DynamicCollectionView";
    Class class = NSClassFromString(view);
    if (class && [class respondsToSelector:@selector(componentForChannel:)]) {
        UIViewController * vc = [class componentForChannel:channel];
        vc.title = [channel titleForChannel];
        return vc;
    } else {
        NSLog(@"No way to handle view type %@, \n%@",view,channel);
    }
    return nil;
}


@end

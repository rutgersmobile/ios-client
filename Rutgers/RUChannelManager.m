//
//  RUComponentManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "Reader.h"
#import "www.h"
#import "RUNetworkManager.h"
#import "RUChannelManager.h"
#import "RUInfoTableViewController.h"
#import "dtable.h"
#import "RUBusViewController.h"
#import "RUPlacesTableViewController.h"
#import "RUFoodViewController.h"
#import "RUMapsViewController.h"
#import "RUMenuController.h"


@interface RUChannelManager ()
@property NSArray *webChannels;
@property NSArray *channels;
@property dispatch_group_t shortcutsGroup;
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
-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel{
    UIViewController * vc;
    NSString *view = channel[@"view"];
    //everthing from shortcuts.txt will get a view of www
    if ([self.webChannels containsObject:channel]) view = @"www";
    Class class = NSClassFromString(view);
    if (class) {
        if ([class respondsToSelector:@selector(componentForChannel:)]) {
            vc = [class componentForChannel:channel];
        } else {
            vc = [class component];
            vc.title = channel[@"title"];
        }
    } else {
        NSLog(@"No way to handle view type %@, \n%@",view,channel);
    }
    return vc;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        self.shortcutsGroup = group;
        
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Channels" ofType:@"json"]];
   
        NSError *error;
        if (error && !data) {
            //NSException raise:<#(NSString *)#> format:<#(NSString *), ...#>
        }
        self.channels = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        [self getShortcuts];
    }
    return self;
}

-(void)getShortcuts{
    [[RUNetworkManager jsonSessionManager] GET:@"shortcuts.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.channels = [self.channels arrayByAddingObjectsFromArray:responseObject];
            self.webChannels = responseObject;
            dispatch_group_leave(self.shortcutsGroup);
        } else {
            [self getShortcuts];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self getShortcuts];
    }];
}
-(void)loadChannelsWithUpdateBlock:(void (^)(NSArray *channels))updateBlock{
    updateBlock([self.channels copy]);
    dispatch_group_notify(self.shortcutsGroup, dispatch_get_main_queue(), ^{
        updateBlock([self.channels copy]);
    });
}




@end

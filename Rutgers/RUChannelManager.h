//
//  RUComponentManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RUDataLoadingManager.h"

extern NSString *const ChannelManagerDidUpdateChannelsKey;

@interface RUChannelManager : RUDataLoadingManager
+(RUChannelManager *)sharedInstance;
-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel;
-(NSArray *)viewControllersForURL:(NSURL *)url;

@property (readonly) NSArray *allChannels;
//-(NSDictionary *)channelWithHandle:(NSString *)handle;
@property NSDictionary *lastChannel;

@end

//
//  RUComponentManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


/*
    Descript: 
        Channel : Different Communication Channels to different services or something else ?
 
 
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RUDataLoadingManager.h"
#import "RUChannelProtocol.h"

#import "DynamicTableViewController.h"


extern NSString *const ChannelManagerDidUpdateChannelsKey;

@interface RUChannelManager : RUDataLoadingManager
+(RUChannelManager *)sharedInstance;

-(void)registerClass:(Class)class;

-(UIViewController <RUChannelProtocol>*)viewControllerForChannel:(NSDictionary *)channel;
-(NSArray *)viewControllersForURL:(NSURL *)url destinationTitle:(NSString *)destinationTitle;

@property (readonly) NSArray *contentChannels;
-(NSDictionary *)channelWithHandle:(NSString *)handle;
@property NSDictionary *lastChannel;

@property (readonly) NSArray *otherChannels;
@end

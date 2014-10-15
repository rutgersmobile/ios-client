//
//  RUComponentManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUChannelManager : NSObject
+(RUChannelManager *)sharedInstance;
-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel;

@property (readonly) NSArray *nativeChannels;
-(void)webLinksWithCompletion:(void(^)(NSArray *webLinks))completion;

@property (readonly) NSArray *allChannels;

@property NSDictionary *lastChannel;
@end

//
//  RUComponentManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RUChannelManagerDelegate <NSObject>
-(void)loadedNewChannels:(NSArray *)newChannels;
@end

@interface RUChannelManager : NSObject
+(RUChannelManager *)sharedInstance;
@property (weak) id<RUChannelManagerDelegate> delegate;
-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel;
-(void)loadChannels;
@end

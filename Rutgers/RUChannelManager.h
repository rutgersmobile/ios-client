//
//  RUComponentManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RUComponentDelegate;

@interface RUChannelManager : NSObject
+(RUChannelManager *)sharedInstance;

-(UIViewController *)viewControllerForChannel:(NSDictionary *)channel delegate:(id)delegate;
-(void)loadChannelsWithUpdateBlock:(void (^)(NSArray *channels))updateBlock;

-(NSString *)identifierForChannel:(NSDictionary *)channel;
-(NSString *)titleForChannel:(NSDictionary *)channel;

@end

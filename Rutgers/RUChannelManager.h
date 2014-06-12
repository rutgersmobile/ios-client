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
-(NSArray *)loadChannels;
-(void)loadWebLinksWithCompletion:(void(^)(NSArray *webLinks))completion;
@end

//
//  RUChannelProtocol.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RUChannelProtocol <NSObject>
@required
/**
 *  The main initialization method of each channel
 *
 *  @param channel The dictionary containing the channel description
 *  @abstract The channel manager uses the channel handle to locate the proper class, and then sends this message to that class
 *
 *  @return The initialized view controller
 */
+(id)channelWithConfiguration:(NSDictionary *)channelConfiguration;

@optional
+(NSArray *)viewControllersWithPathComponents:(NSArray *)pathComponents destinationTitle:(NSString *)title;
@end

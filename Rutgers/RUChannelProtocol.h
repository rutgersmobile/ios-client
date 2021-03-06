//
//  RUChannelProtocol.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


/*
 Descript : 
         Used to locate which view to show to the user : 
       
        May be used from the sidebar to obtian the particular view controller
 
 
 */

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
+(NSString *)channelHandle;

@optional

+(NSArray *)viewControllersWithPathComponents:(NSArray *)pathComponents destinationTitle:(NSString *)title;



@end

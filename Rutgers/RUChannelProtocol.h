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
+(id)channelWithConfiguration:(NSDictionary *)channel;
//@property (nonatomic, readonly) NSDictionary *channelConfiguration;
@end

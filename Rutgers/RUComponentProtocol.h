//
//  RUComponentProtocol.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RUComponentProtocol <NSObject>
+(instancetype)componentForChannel:(NSDictionary *)channel;
@end

//
//  RUWebChannelManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/2/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUWebComponent.h"

@interface RUWebChannelManager : NSObject

+(RUWebChannelManager *)sharedInstance;

-(RUWebComponent *)webComponentWithURL:(NSURL *)url title:(NSString *)title delegate:(id<RUComponentDelegate>)delegate;

@end

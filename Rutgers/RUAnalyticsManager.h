//
//  RUAnalyticsManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/26/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUAnalyticsManager : NSObject
+(instancetype)sharedManager;
-(void)queueEventForApplicationStart;
-(void)queueEventForError:(NSError *)error;
-(void)queueEventForChannelOpen:(NSDictionary *)channel;
-(void)flushQueue;
@end

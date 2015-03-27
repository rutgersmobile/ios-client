//
//  NSDictionary+Channel.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Channel)

-(NSString *)channelTitle;

-(UIImage *)channelIcon;
-(UIImage *)filledChannelIcon;

-(NSString *)channelHandle;

-(NSString *)channelURL;

-(NSString *)channelView;

-(BOOL)channelIsWebLink;
@end

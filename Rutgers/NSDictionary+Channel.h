//
//  NSDictionary+Channel.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/15/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Channel)

@property (nonatomic, readonly) NSString *channelTitle;

@property (nonatomic, readonly) UIImage *channelIcon;
@property (nonatomic, readonly) UIImage *filledChannelIcon;

@property (nonatomic, readonly) NSString *channelHandle;

@property (nonatomic, readonly) NSString *channelURL;

@property (nonatomic, readonly) NSString *channelView;

@property (nonatomic, readonly) BOOL channelIsWebLink;

@property (nonatomic, readonly) BOOL presentsModally;
@end

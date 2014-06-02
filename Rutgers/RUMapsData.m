//
//  RUMapsData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsData.h"

@interface RUMapsData ()
@end

@implementation RUMapsData
+(RUMapsData *)sharedInstance{
    static RUMapsData *mapsData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapsData = [[RUMapsData alloc] init];
    });
    return mapsData;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

@end


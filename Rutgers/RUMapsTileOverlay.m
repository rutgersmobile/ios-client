//
//  RUMapsTileOverlay.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import "iPadCheck.h"

@interface RUMapsTileOverlay ()
@property BOOL retina;
@end

@implementation RUMapsTileOverlay
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.canReplaceMapContent = YES;
    }
    return self;
}
-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *data, NSError *error))result{
    [self.delegate loadTileAtPath:path result:result];

}

@end
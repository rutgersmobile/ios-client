//
//  RUMapsTileOverlay.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
@interface RUMapsTileOverlay ()
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
-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result{
    [self.delegate loadTileAtPath:path result:result];
}
@end
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
-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result{
    [[RUMapsData sharedInstance] loadTileAtPath:path result:result];
}

@end
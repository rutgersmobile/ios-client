//
//  RUMapsTileOverlay.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol RUMapsTileOverlayDelegate <NSObject>
-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result;
@end

@interface RUMapsTileOverlay : MKTileOverlay
@property id <RUMapsTileOverlayDelegate> delegate;
@end

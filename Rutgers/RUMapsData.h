//
//  RUMapsData.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RUMapsData : NSObject
+(RUMapsData *)sharedInstance;
-(NSURL *)URLForTilePath:(MKTileOverlayPath)path;

-(NSData *)cachedDataForTilePath:(MKTileOverlayPath)path;
-(void)setCachedData:(NSData *)data forTilePath:(MKTileOverlayPath)path;
@end

//
//  RUMapsData.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsData.h"

@interface RUMapsData ()
@property NSCache *cache;
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


- (NSURL *)URLForTilePath:(MKTileOverlayPath)path {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://sauron.rutgers.edu/maps/%@.png", [self keyForOverlayPath:path]]];
}

-(NSString *)keyForOverlayPath:(MKTileOverlayPath)path{
    return [NSString stringWithFormat:@"%ld/%ld/%ld", (long)path.z, (long)path.x, (long)path.y];
}

-(NSData *)cachedDataForTilePath:(MKTileOverlayPath)path{
    return [self.cache objectForKey:[self keyForOverlayPath:path]];
}

-(void)setCachedData:(NSData *)data forTilePath:(MKTileOverlayPath)path{
    [self.cache setObject:data forKey:[self keyForOverlayPath:path] cost:data.length];
}
@end


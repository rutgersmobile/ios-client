//
//  RowHeightCache.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RowHeightCache : NSObject
-(void)invalidateCachedHeights;
-(void)invalidateCachedHeightsForSection:(NSInteger)section;
-(void)invalidateCachedHeightsForIndexPaths:(NSArray *)indexPaths;

-(NSNumber *)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)setCachedHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

//
//  RowHeightCache.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The row height cache used by the TableViewController to record the heights of rows in the table
 *  This saves time because we would otherwise need to recalcuate it
 */
@interface RowHeightCache : NSObject

/**
 *  Get the cached height for an indexPath
 *  The value is boxed in a NSNumber object, to handle when there is an absence of a cached height
 *  @return A boxed height, or nil
 */
-(NSNumber *)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)setCachedHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Invalidate the cache, either the whole thing, just a section, or particular index paths
 */
-(void)invalidateCachedHeights;
-(void)invalidateCachedHeightsForSection:(NSInteger)section;
-(void)invalidateCachedHeightsForIndexPaths:(NSArray *)indexPaths;
@end

//
//  NSIndexPath+RowExtensions.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (RowExtensions)
+(NSArray *)indexPathsForRange:(NSRange)range inSection:(NSInteger)section;
@end

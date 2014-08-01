//
//  ExpandingTableViewSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewSection.h"
#import "NSIndexPath+RowExtensions.h"
#import "DataSource_Private.h"

@interface ExpandingTableViewSection ()

@end

@implementation ExpandingTableViewSection

-(void)setExpanded:(BOOL)expanded{
    
    NSInteger oldCount = self.numberOfItems;
    _expanded = expanded;
    NSInteger newCount = self.numberOfItems;
    
    if (expanded) {
        [self notifyItemsInsertedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(oldCount, newCount-oldCount) inSection:0]];
    } else {
        [self notifyItemsRemovedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(newCount, oldCount-newCount) inSection:0]];
    }
}

-(NSInteger)numberOfItems{
    NSInteger numberOfItems = [super numberOfItems];
    return self.expanded ? numberOfItems : MIN(numberOfItems, 1);
}

-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0) {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
}
@end

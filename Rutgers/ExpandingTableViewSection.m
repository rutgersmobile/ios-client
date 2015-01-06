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
    
    if ([super numberOfItems] <= 1){
        _expanded = NO;
        return;
    } else {
        _expanded = expanded;
    }
    
    NSInteger newCount = self.numberOfItems;
    
    [self invalidateCachedHeightsForIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(1, newCount-1) inSection:0]];
    if (expanded) {
        [self notifyBatchUpdate:^{
            [self notifyItemsRefreshedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, oldCount) inSection:0]];
            [self notifyItemsInsertedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(oldCount, newCount-oldCount) inSection:0]];
        }];
    } else {
        [self notifyBatchUpdate:^{
            [self notifyItemsRefreshedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(0, newCount) inSection:0]];
            [self notifyItemsRemovedAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(newCount, oldCount-newCount) inSection:0]];
        }];
    }
}

-(NSInteger)numberOfItems{
    NSInteger numberOfItems = [super numberOfItems];
    return self.expanded ? numberOfItems : MIN(numberOfItems, 1);
}

-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIEdgeInsets insets =  UIEdgeInsetsMake(0, kLabelHorizontalInsets, 0, 0);
    
    if (indexPath.row != 0) {
        cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.separatorInset = UIEdgeInsetsZero;
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.separatorInset = self.expanded ? UIEdgeInsetsZero : insets;
    }
}

@end

//
//  ExpandingTableViewSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewSection.h"
#import "NSIndexPath+RowExtensions.h"

@interface ExpandingTableViewSection ()
@property (nonatomic) EZTableViewAbstractRow *headerRow;
@end
@implementation ExpandingTableViewSection
-(instancetype)initWithHeaderRow:(EZTableViewAbstractRow *)headerRow bodyRows:(NSArray *)bodyRows{
    self = [super initWithItems:bodyRows];
    if (self) {
        self.headerRow = headerRow;
    }
    return self;
}

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

-(NSInteger)numberOfRows{
    if (self.expanded) {
        return [super numberOfItems]+1;
    } else {
        return 1;
    }
}
-(EZTableViewAbstractRow *)itemAtIndex:(NSInteger)index{
    if (index == 0) {
        return self.headerRow;
    } else {
        return [super itemAtIndex:index-1];
    }
}
@end

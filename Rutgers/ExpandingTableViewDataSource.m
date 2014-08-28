//
//  ExpandingTableViewDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewDataSource.h"
#import "ExpandingTableViewSection.h"
#import "ComposedDataSource_Private.h"

@interface ExpandingTableViewDataSource ()
@end

@implementation ExpandingTableViewDataSource
-(void)setSections:(NSArray *)sections{
    [self setSections:sections animated:YES];
}

-(NSArray *)sections{
    return self.dataSources;
}

-(void)setSections:(NSArray *)sections animated:(BOOL)animated{
    if (self.sections == sections || [self.sections isEqualToArray:sections])
        return;
    
    if (!animated) {
        self.sections = [sections copy];
        [self invalidateCachedHeights];
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sections.count)]];
        return;
    }
    
    NSOrderedSet *oldSectionSet = [NSOrderedSet orderedSetWithArray:self.sections];
    NSOrderedSet *newSectionSet = [NSOrderedSet orderedSetWithArray:sections];
    
    NSMutableOrderedSet *deletedSections = [oldSectionSet mutableCopy];
    [deletedSections minusOrderedSet:newSectionSet];
    
    NSMutableOrderedSet *newSections = [newSectionSet mutableCopy];
    [newSections minusOrderedSet:oldSectionSet];
    
    NSMutableOrderedSet *movedSections = [newSectionSet mutableCopy];
    [movedSections intersectOrderedSet:oldSectionSet];
    
    NSIndexSet *deletedIndexes = [oldSectionSet indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [deletedSections containsObject:obj];
    }];
    
    NSIndexSet *insertedIndexes = [newSectionSet indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [newSections containsObject:obj];
    }];
    
    NSIndexSet *fromMovedIndexes = [movedSections indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [oldSectionSet containsObject:obj];
    }];
    
    NSIndexSet *toMovedIndexes = [movedSections indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [newSectionSet containsObject:obj];
    }];
    
    [sections enumerateObjectsUsingBlock:^(DataSource *dataSource, NSUInteger idx, BOOL *stop) {
        dataSource.delegate = self;
    }];
    
    [self notifyBatchUpdate:^{
        [self invalidateCachedHeights];

        self.dataSources = [sections copy];
        
        if ([deletedIndexes count])
            [self notifySectionsRemoved:deletedIndexes direction:DataSourceOperationDirectionRight];
        
        if ([insertedIndexes count])
            [self notifySectionsInserted:insertedIndexes direction:DataSourceOperationDirectionLeft];
        
        NSUInteger fromIndex = [fromMovedIndexes firstIndex];
        NSUInteger toIndex = [toMovedIndexes firstIndex];

        while (fromIndex != NSNotFound && toIndex != NSNotFound) {
            [self notifySectionMovedFrom:fromIndex to:toIndex];
            
            fromIndex = [fromMovedIndexes indexGreaterThanIndex:fromIndex];
            toIndex = [toMovedIndexes indexGreaterThanIndex:toIndex];
        }
    }];
}

-(ExpandingTableViewSection *)sectionAtIndex:(NSInteger)index{
    return self.sections[index];
}

-(void)toggleExpansionForSection:(NSUInteger)section{
    ExpandingTableViewSection *expandingSection = [self sectionAtIndex:section];
    expandingSection.expanded = !expandingSection.expanded;
}

@end

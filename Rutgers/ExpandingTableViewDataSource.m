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
#import "DataSource_Private.h"

@interface ExpandingTableViewDataSource ()
@end

@implementation ExpandingTableViewDataSource
-(instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

-(NSArray *)sections{
    return self.dataSources;
}

-(void)setSections:(NSArray *)sections{
    self.dataSources = [sections mutableCopy];
}

-(ExpandingTableViewSection *)sectionAtIndex:(NSInteger)index{
    return self.sections[index];
}

-(void)toggleExpansionForSection:(NSUInteger)section{
    ExpandingTableViewSection *expandingSection = [self sectionAtIndex:section];
    expandingSection.expanded = !expandingSection.expanded;
}

@end

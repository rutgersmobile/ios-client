//
//  ExpandingTableViewSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewSection.h"
@interface ExpandingTableViewSection ()
@property (nonatomic) EZTableViewAbstractRow *headerRow;
@end
@implementation ExpandingTableViewSection
-(instancetype)initWithHeaderRow:(EZTableViewAbstractRow *)headerRow bodyRows:(NSArray *)bodyRows{
    self = [super initWithSectionTitle:nil rows:bodyRows];
    if (self) {
        self.headerRow = headerRow;
    }
    return self;
}
-(NSInteger)numberOfRows{
    if (self.expanded) {
        return [super numberOfRows]+1;
    } else {
        return 1;
    }
}
-(EZTableViewAbstractRow *)rowAtIndex:(NSInteger)index{
    if (index == 0) {
        return self.headerRow;
    } else {
        return [super rowAtIndex:index-1];
    }
}
@end

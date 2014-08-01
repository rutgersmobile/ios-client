//
//  FAQDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "FAQDataSource.h"
#import "ALTableViewTextCell.h"
#import "ExpandingTableViewSection.h"
#import "FAQSectionDataSource.h"

@interface FAQDataSource ()
@property NSArray *items;
@end

@implementation FAQDataSource
-(instancetype)initWithItems:(NSArray *)items{
    self = [super init];
    if (self) {
        self.items = items;
        
        for (NSDictionary *item in self.items) {
            [self addDataSource:[[FAQSectionDataSource alloc] initWithItem:item]];
        }
    }
    return self;
}

@end

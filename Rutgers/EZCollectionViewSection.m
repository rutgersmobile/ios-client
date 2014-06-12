//
//  EZCollectionViewSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZCollectionViewSection.h"
@interface EZCollectionViewSection ()
@property (nonatomic) NSMutableArray *items;
@end
@implementation EZCollectionViewSection
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray array];
    }
    return self;
}
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle{
    self = [super init];
    if (self) {
        self.title = sectionTitle;
    }
    return self;
}

-(instancetype)initWithSectionTitle:(NSString *)sectionTitle items:(NSArray *)items{
    self = [self initWithSectionTitle:sectionTitle];
    if (self) {
        [self.items addObjectsFromArray:items];
    }
    return self;
}

-(void)addItem:(EZCollectionViewAbstractItem *)item{
    [self.items addObject:item];
}

-(void)addItems:(NSArray *)items{
    [self.items addObjectsFromArray:items];
}

-(void)removeAllItems{
    [self.items removeAllObjects];
}

-(NSInteger)numberOfItems{
    return self.items.count;
}

-(EZCollectionViewAbstractItem *)itemAtIndex:(NSInteger)index{
    return self.items[index];
}
@end

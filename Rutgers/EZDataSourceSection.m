//
//  EZTableViewSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZDataSourceSection.h"
#import "EZTableViewRightDetailRow.h"

@interface EZDataSourceSection ()
@end

@implementation EZDataSourceSection

#pragma mark - Initialization
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rows = [NSArray array];
    }
    return self;
}

-(instancetype)initWithSectionTitle:(NSString *)sectionTitle{
    self = [self init];
    if (self) {
        self.title = sectionTitle;
    }
    return self;
}

-(instancetype)initWithSectionTitle:(NSString *)sectionTitle items:(NSArray *)rows{
    self = [self initWithSectionTitle:sectionTitle];
    if (self) {
        [self addItems:rows];
    }
    return self;
}

-(instancetype)initWithItems:(NSArray *)rows{
    self = [self init];
    if (self) {
        [self addItems:rows];
    }
    return self;
}

#pragma mark - Adding and removing items
-(void)setRows:(NSArray *)rows{
    self.items = rows;
}

-(NSArray *)rows{
    return self.items;
}

-(void)addItem:(EZTableViewRightDetailRow *)row{
    self.rows = [self.rows arrayByAddingObject:row];
}

-(void)addItems:(NSArray *)rows{
    self.rows = [self.rows arrayByAddingObjectsFromArray:rows];
}

-(NSInteger)numberOfRows{
    return self.rows.count;
}

-(EZTableViewRightDetailRow *)itemAtIndex:(NSInteger)index{
    return self.rows[index];
}


-(NSString *)identifierForCellAtIndexPath:(NSIndexPath *)indexPath{
    return [self itemAtIndex:indexPath.row].identifier;
}

-(NSString *)identifierForHeaderInSection:(NSInteger)section{
 return nil;
}

@end

//
//  EZTableViewSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZDataSourceSection.h"
#import "EZTableViewRightDetailRow.h"
#import "ALTableViewAbstractCell.h"

@interface EZDataSourceSection ()
@end

@implementation EZDataSourceSection

#pragma mark - Initialization

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

-(void)addItem:(EZTableViewAbstractRow *)row{
    self.items = [self.items arrayByAddingObject:row];
}

-(void)addItems:(NSArray *)rows{
    self.items = [self.items arrayByAddingObjectsFromArray:rows];
}

-(NSInteger)numberOfRows{
    return self.items.count;
}

-(EZTableViewAbstractRow *)itemAtIndex:(NSInteger)index{
    return self.items[index];
}

-(NSString *)identifierForCellAtIndexPath:(NSIndexPath *)indexPath{
    return [self itemAtIndex:indexPath.row].identifier;
}

-(NSString *)identifierForHeaderInSection:(NSInteger)section{
    return nil;
}

#pragma mark - table view delegate 
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [self itemAtIndex:indexPath.row].identifier;
    ALTableViewAbstractCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        [tableView registerClass:NSClassFromString(identifier) forCellReuseIdentifier:identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    EZTableViewAbstractRow *item = [self itemAtIndexPath:indexPath];
    [item setupCell:cell];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}


@end

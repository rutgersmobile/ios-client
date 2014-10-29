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
    self = [self initWithItems:@[]];
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
    self = [super initWithItems:rows];
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

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self itemAtIndex:indexPath.row].identifier;
}

-(id)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier{
    ALTableViewAbstractCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        [tableView registerClass:NSClassFromString(reuseIdentifier) forCellReuseIdentifier:reuseIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    }
    return cell;
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewAbstractRow *item = [self itemAtIndexPath:indexPath];
    [item setupCell:cell];
}



@end

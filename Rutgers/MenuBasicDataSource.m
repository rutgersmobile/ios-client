//
//  MenuBasicDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "MenuBasicDataSource.h"
#import "RUMenuTableViewCell.h"
#import "AAPLPlaceholderView.h"
#import "DataSource_Private.h"

@implementation MenuBasicDataSource

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUMenuTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUMenuTableViewCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUMenuTableViewCell class]);
}

/*
    This does not seem to have any effect on the program
    Should the configutation be in the view controller ?
    Changing the cell configutation here has not effect , may it is being over ridden somewhere else ?
 */
-(void)configureCell:(RUMenuTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *channel = [self itemAtIndexPath:indexPath];
    [cell setupForChannel:channel];
}

-(void)configurePlaceholderCell:(ALPlaceholderCell *)cell{
    [super configurePlaceholderCell:cell];
    cell.backgroundColor = [UIColor clearColor];
}

@end

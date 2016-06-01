//
//  RUMenuMultipleDataSource.m
//  Rutgers
//
//  Created by scm on 5/31/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUMenuMultipleDataSource.h"
#import "RUFavoritesDataSource.h"
#import "ChannelsDataSource.h"
#import "RUMenuTableViewCell.h"

@implementation RUMenuMultipleDataSource

-(instancetype) init
{
    self = [super init];
    if(self)
    {
    
        NSMutableArray *multipeArray = [[NSMutableArray alloc] init] ;
        [multipeArray addObjectsFromArray:[[RUFavoritesDataSource alloc] init].items];
        [multipeArray addObjectsFromArray:[[ChannelsDataSource alloc] init].items];
        self.items = [multipeArray copy];
    }
    
    return self;
}

/*
    Configure the cell properly
 */
-(void)configureCell:(RUMenuTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *channel = [self itemAtIndexPath:indexPath];
    [cell setupForChannelForEditOptions:channel];
}

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

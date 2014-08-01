//
//  BusBasicDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BusBasicDataSource.h"
#import "ALTableViewTextCell.h"

@implementation BusBasicDataSource

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ALTableViewTextCell class])];
   
    id item = [self itemAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [item title];
    cell.textLabel.textColor = [item active] ? [UIColor blackColor] : [UIColor lightGrayColor];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}
@end
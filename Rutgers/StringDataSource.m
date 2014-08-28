//
//  StringDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "StringDataSource.h"
#import "ALTableViewTextCell.h"

@implementation StringDataSource
-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    id string = [self itemAtIndexPath:indexPath];
    if ([string isKindOfClass:[NSString class]]) {
        cell.textLabel.text = string;
    } else if ([string isKindOfClass:[NSAttributedString class]]) {
        cell.textLabel.attributedText = string;
    }
    cell.accessoryType = self.showsDisclosureIndicator ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

@end

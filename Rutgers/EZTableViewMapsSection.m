//
//  EZTableViewMapsSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewMapsSection.h"
#import "EZTableViewMapsRow.h"
#import "RUMapsTableViewCell.h"

@implementation EZTableViewMapsSection
-(instancetype)initWithSectionTitle:(NSString *)sectionTitle place:(RUPlace *)place{
    self = [super initWithSectionTitle:sectionTitle];
    if (self) {
        [self addItem:[[EZTableViewMapsRow alloc] initWithPlace:place]];
    }
    return self;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[RUMapsTableViewCell class] rowHeight];
}

@end

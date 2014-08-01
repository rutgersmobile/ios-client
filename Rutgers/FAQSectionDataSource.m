//
//  FAQSectionDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "FAQSectionDataSource.h"
#import "ALTableViewTextCell.h"

@interface FAQSectionDataSource ()
@property NSDictionary *item;
@end

@implementation FAQSectionDataSource

-(instancetype)initWithItem:(NSDictionary *)item{
    id children = item[@"children"];
    NSArray *items;
    
    if (![children isKindOfClass:[NSArray class]]) {
        items = @[item[@"title"],item[@"answer"]];
    } else {
        items = @[item];
    }

    self = [super initWithItems:items];
    if (self) {
        self.item = item;
    }
    return self;
}


-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewTextCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ALTableViewTextCell class])];
    NSString *stringForIndex;
    id itemForIndex = [self itemAtIndexPath:indexPath];
    
    if ([itemForIndex isKindOfClass:[NSString class]]) {
        stringForIndex = itemForIndex;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else if ([itemForIndex isKindOfClass:[NSDictionary class]]) {
        stringForIndex = itemForIndex[@"title"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = stringForIndex;
    cell.textLabel.font = (indexPath.row == 0) ? [UIFont boldSystemFontOfSize:18] : [UIFont systemFontOfSize:16];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}
@end

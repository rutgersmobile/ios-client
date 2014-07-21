//
//  ExpandingTableViewDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewDataSource.h"
#import "ExpandingTableViewSection.h"

@implementation ExpandingTableViewDataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZDataSourceSection *section = [self sectionAtIndex:indexPath.section];
    
    if (![section isKindOfClass:[ExpandingTableViewSection class]]) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    
    if (indexPath.row != 0) return;
    
    ExpandingTableViewSection *expandingSection = (ExpandingTableViewSection *)section;
    
    expandingSection.expanded = !expandingSection.expanded;
 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row != 0 && [[self sectionAtIndex:indexPath.section] isKindOfClass:[ExpandingTableViewSection class]]) {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row == 0);
}

@end

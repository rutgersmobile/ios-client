//
//  ExpandingTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ExpandingTableViewController.h"
#import "ExpandingTableViewSection.h"
#import "NSIndexPath+RowExtensions.h"

@interface ExpandingTableViewController ()
@property NSArray *insertingIndexPaths;
@end

@implementation ExpandingTableViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewSection *section = self.sections[indexPath.section];

    if (![section isKindOfClass:[ExpandingTableViewSection class]]) {
       
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
 
    } else {
        if (indexPath.row != 0) return;
        
        ExpandingTableViewSection *section = self.sections[indexPath.section];
        
        NSInteger oldCount = section.numberOfRows;
        section.expanded = !section.expanded;
        NSInteger newCount = section.numberOfRows;
        
        UITableViewRowAnimation animationType = UITableViewRowAnimationFade;
        
        BOOL nowExpanded = section.expanded;
        
        if (nowExpanded) {
            self.insertingIndexPaths = [NSIndexPath indexPathsForRange:NSMakeRange(oldCount, newCount-oldCount) inSection:indexPath.section];
            [tableView insertRowsAtIndexPaths:self.insertingIndexPaths  withRowAnimation:animationType];
            self.insertingIndexPaths = nil;

        } else {
            [tableView deleteRowsAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(newCount, oldCount-newCount) inSection:indexPath.section] withRowAnimation:animationType];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row != 0 && [[self sectionInTableView:tableView atIndex:indexPath.section] isKindOfClass:[ExpandingTableViewSection class]]) {
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.insertingIndexPaths containsObject:indexPath]) {
        return [self tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return [super tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
}


-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row == 0);
}

@end

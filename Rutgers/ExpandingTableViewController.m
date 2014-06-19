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

@end

@implementation ExpandingTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0) return;
    
    ExpandingTableViewSection *section = self.sections[indexPath.section];
    
    NSInteger oldCount = section.numberOfRows;
    section.expanded = !section.expanded;
    NSInteger newCount = section.numberOfRows;

    UITableViewRowAnimation animationType = UITableViewRowAnimationFade;
    
    BOOL nowExpanded = section.expanded;
    if (nowExpanded) {
        NSArray *insertedIndexPaths = [NSIndexPath indexPathsForRange:NSMakeRange(oldCount, newCount-oldCount) inSection:indexPath.section];
        [tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:animationType];
        NSArray *visibleIndexPaths = [tableView indexPathsForVisibleRows];
        NSInteger index = [visibleIndexPaths indexOfObject:indexPath];
        if (index > visibleIndexPaths.count - 4) {
            [tableView scrollToRowAtIndexPath:[insertedIndexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    } else {
        [tableView deleteRowsAtIndexPaths:[NSIndexPath indexPathsForRange:NSMakeRange(newCount, oldCount-newCount) inSection:indexPath.section] withRowAnimation:animationType];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
 //   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row == 0);
}

@end

//
//  RULegalViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RULegalViewController.h"
#import "TableViewController_Private.h"
#import "LegalDataSource.h"

@interface RULegalViewController ()

@end

@implementation RULegalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Legal Notices";
    self.tableView.estimatedRowHeight = 0;
    self.dataSource = [[LegalDataSource alloc] init];
}

-(BOOL)respondsToSelector:(SEL)aSelector{
    if (aSelector == @selector(tableView:estimatedHeightForRowAtIndexPath:)) return NO;
    return [super respondsToSelector:aSelector];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
    return NO;
}

@end

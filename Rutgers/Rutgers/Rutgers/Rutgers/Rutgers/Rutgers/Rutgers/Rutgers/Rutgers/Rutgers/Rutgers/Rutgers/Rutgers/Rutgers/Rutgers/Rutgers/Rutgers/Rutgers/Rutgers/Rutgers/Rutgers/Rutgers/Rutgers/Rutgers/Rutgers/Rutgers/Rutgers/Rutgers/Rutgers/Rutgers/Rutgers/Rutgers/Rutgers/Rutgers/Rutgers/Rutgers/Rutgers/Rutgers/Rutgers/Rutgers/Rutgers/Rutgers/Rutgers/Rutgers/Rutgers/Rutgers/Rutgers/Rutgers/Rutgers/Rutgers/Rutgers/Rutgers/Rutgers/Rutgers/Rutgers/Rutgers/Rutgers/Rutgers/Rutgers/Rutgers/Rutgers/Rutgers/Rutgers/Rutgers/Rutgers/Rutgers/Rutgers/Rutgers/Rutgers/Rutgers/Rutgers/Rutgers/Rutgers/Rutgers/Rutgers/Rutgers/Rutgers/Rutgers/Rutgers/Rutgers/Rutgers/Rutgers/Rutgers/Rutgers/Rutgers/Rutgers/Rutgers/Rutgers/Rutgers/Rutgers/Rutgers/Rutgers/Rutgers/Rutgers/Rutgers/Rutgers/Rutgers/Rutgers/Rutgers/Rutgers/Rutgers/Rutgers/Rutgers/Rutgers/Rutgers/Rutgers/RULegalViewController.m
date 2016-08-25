//
//  RULegalViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RULegalViewController.h"
#import "LegalDataSource.h"

@interface RULegalViewController ()

@end

@implementation RULegalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Legal Notices";
    //No row height estimation
    self.tableView.estimatedRowHeight = 0;
    self.dataSource = [[LegalDataSource alloc] init];
}

/**
 *  Force no row height estimation because these rows are huge
 *  The method is implemented in the superclass, but here we want to 'unimplement' it
 *  The view controllers table view will ask if it responds to this delegate message
 *  We will just always respond no when asked
 */
-(BOOL)respondsToSelector:(SEL)aSelector{
    if (aSelector == @selector(tableView:estimatedHeightForRowAtIndexPath:)) return NO;
    return [super respondsToSelector:aSelector];
}

//Dont allow selection of anything
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
    return NO;
}

@end

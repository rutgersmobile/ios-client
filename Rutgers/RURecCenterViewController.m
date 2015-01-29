 //
//  RURecCenterViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterViewController.h"
#import "TableViewController_Private.h"
#import "RUPlace.h"
#import "RUMapsViewController.h"
#import "RURecCenterDataSource.h"
#import "DataTuple.h"

#import <NSString+HTML.h>
#import "NSAttributedString+FromHTML.h"

@interface RURecCenterViewController ()
@property (nonatomic) NSDictionary *recCenter;
@end

@implementation RURecCenterViewController
- (instancetype)initWithTitle:(NSString *)title recCenter:(NSDictionary *)recCenter
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = title;
        self.recCenter = recCenter;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.dataSource = [[RURecCenterDataSource alloc] initWithRecCenter:self.recCenter];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[DataTuple class]]) {
        DataTuple *tuple = item;
        [self.navigationController pushViewController:[[RUMapsViewController alloc] initWithPlace:tuple.object] animated:YES];
    }
}

-(BOOL)showMenuForItem:(id)item{
    return [item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSAttributedString class]];
}

-(BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return [self showMenuForItem:item];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return action == @selector(copy:) && [self showMenuForItem:item];
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (action != @selector(copy:)) return;
    
    id item = [self.dataSource itemAtIndexPath:indexPath];
    
    if ([item isKindOfClass:[NSString class]]) {
        [UIPasteboard generalPasteboard].string = item;
    } else if ([item isKindOfClass:[NSAttributedString class]]) {
        [UIPasteboard generalPasteboard].string = ((NSAttributedString *)item).string;
    }
}

@end

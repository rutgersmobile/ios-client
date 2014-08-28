//
//  RUPlaceDetailTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlaceDetailViewController.h"
#import "RUPredictionsViewController.h"
#import "RUMapsViewController.h"
#import "RUPlacesViewController.h"
#import "RUPlaceDetailDataSource.h"
#import "RUMultiStop.h"
#import "EZTableViewMapsRow.h"
#import "RUPlace.h"

@interface RUPlaceDetailViewController ()
@property (nonatomic) RUPlace *place;

@end

@implementation RUPlaceDetailViewController

-(id)initWithPlace:(RUPlace *)place{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.place = place;
        self.title = place.title;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.dataSource = [[RUPlaceDetailDataSource alloc] initWithPlace:self.place];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[EZTableViewMapsRow class]]) {
        [self.navigationController pushViewController:[[RUMapsViewController alloc] initWithPlace:self.place] animated:YES];
    } else if ([item isKindOfClass:[RUMultiStop class]]) {
         [self.navigationController pushViewController:[[RUPredictionsViewController alloc] initWithItem:item] animated:YES];
    }
}

-(BOOL)showMenuForItem:(id)item{
    return [item isKindOfClass:[NSString class]];
}

-(BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return [self showMenuForItem:item];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return ![self showMenuForItem:item];
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    return action == @selector(copy:) && [self showMenuForItem:item];
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (action != @selector(copy:)) return;
    NSString *item = [self.dataSource itemAtIndexPath:indexPath];
    [UIPasteboard generalPasteboard].string = item;
}

@end

//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMenuViewController.h"
#import "MenuDataSource.h"
#import "UITableView+Selection.h"
#import "UIApplication+StatusBarHeight.h"
#import "TableViewController_Private.h"

@interface RUMenuViewController ()
@property (nonatomic) UIView *paddingView;
@property (nonatomic) NSDictionary *currentChannel;
@end

@implementation RUMenuViewController
- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Menu";
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.dataSource = [[MenuDataSource alloc] init];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 32+kLabelHorizontalInsets*2, 0, 0);
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    self.currentChannel = [RUChannelManager sharedInstance].lastChannel;
    NSIndexPath *indexPath = [[self.dataSource indexPathsForItem:self.currentChannel] lastObject];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setContentInsets];
}

-(void)setContentInsets{
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarHeight];
    UIEdgeInsets insets = UIEdgeInsetsMake(statusBarHeight, 0, 0, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    CGPoint offset = self.tableView.contentOffset;
    if (offset.y == 0) offset.y = -insets.top;
    self.tableView.contentOffset = offset;
}

-(void)reloadTablePreservingSelectionState:(UITableView *)tableView{
    if (tableView == self.tableView) {
        [self.tableView reloadData];
        [self.tableView selectRowsAtIndexPaths:[self.dataSource indexPathsForItem:self.currentChannel] animated:NO];
    } else {
        [super reloadTablePreservingSelectionState:tableView];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *channel = [self.dataSource itemAtIndexPath:indexPath];
    if ([channel isEqualToDictionary:self.currentChannel]) {
        [self.delegate menuDidSelectCurrentChannel:self];
    } else {
        self.currentChannel = channel;
        [RUChannelManager sharedInstance].lastChannel = channel;
        [self.delegate menu:self didSelectChannel:channel];
    }
}

@end

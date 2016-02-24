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
#import "RURootController.h"
#import "RUDefines.h"

@interface RUMenuViewController ()
@property (nonatomic) UIView *paddingView;
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
    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    self.dataSource = [[MenuDataSource alloc] init];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 32+kLabelHorizontalInsets*2, 0, 0);
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    NSIndexPath *indexPath = [[self.dataSource indexPathsForItem:[RURootController sharedInstance].selectedItem] lastObject];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
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
}

-(void)reloadTablePreservingSelectionState:(UITableView *)tableView{
    if (tableView == self.tableView) {
        [self.tableView reloadData];
        [self.tableView selectRowsAtIndexPaths:[self.dataSource indexPathsForItem:[RURootController sharedInstance].selectedItem] animated:NO];
    } else {
        [super reloadTablePreservingSelectionState:tableView];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self.dataSource itemAtIndexPath:indexPath];
    [self.delegate menu:self didSelectItem:item];
}
@end

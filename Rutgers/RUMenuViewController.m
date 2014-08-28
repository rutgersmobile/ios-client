//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


#import "RUMenuViewController.h"
#import "MenuDataSource.h"
#import <SWRevealViewController.h>
#import "UITableView+Selection.h"

@interface RUMenuViewController ()
@property (nonatomic) UIView *paddingView;
@property (nonatomic) NSDictionary *currentChannel;
@end

@implementation RUMenuViewController
-(instancetype)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Menu";
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    CGRect statusBarFrame = [self.view convertRect:[[UIApplication sharedApplication] statusBarFrame] fromView:nil];
    CGFloat statusBarHeight = CGRectGetHeight(statusBarFrame);
    
    UIView *paddingView = [UIView newAutoLayoutView];

    [self.view addSubview:paddingView];
    self.paddingView = paddingView;

    [paddingView autoSetDimension:ALDimensionHeight toSize:statusBarHeight];
    [paddingView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    
    self.tableView.contentInset = UIEdgeInsetsMake(statusBarHeight, 0, 0, 0);
    [self.tableView autoRemoveConstraintsAffectingView];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeRight];
    [self.tableView autoSetDimension:ALDimensionWidth toSize:self.revealViewController.rightViewRevealWidth];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.dataSource = [[MenuDataSource alloc] init];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];//[UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 32+kLabelHorizontalInsets*2, 0, 0);
    
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
        [self.delegate menu:self didSelectChannel:channel];
    }
}
@end

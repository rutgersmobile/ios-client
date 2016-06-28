//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMenuViewController.h"
#import "UITableView+Selection.h"
#import "UIApplication+StatusBarHeight.h"
#import "TableViewController_Private.h"
#import "RURootController.h"
#import "RUDefines.h"
#import "Rutgers-Swift.h"

/*
 
    RU Menu is shown within the slide menu bar
 */


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

    self.dataSource = [[RUMenuDataSource alloc] init];
 
    /*
        Sets the graphics opt of the menu slide bar
     */
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 32+kLabelHorizontalInsets*2, 0, 0);
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
   
    /*
        Location where the menu bar moves to the previous selected item
     */
    NSIndexPath *indexPath = [[self.dataSource indexPathsForItem:[RURootController sharedInstance].selectedItem] lastObject];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

/*
    pre auto layout
 */
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setContentInsets];
}

/*
    pre auto layout : 
    see this :
    http://stackoverflow.com/questions/1983463/whats-the-uiscrollview-contentinset-property-for
 */
-(void)setContentInsets{
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarHeight];
    UIEdgeInsets insets = UIEdgeInsetsMake(statusBarHeight, 0, 0, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

// store the state and reload
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
    id item = [self.dataSource itemAtIndexPath:indexPath];
    
   // NSLog(@"%@",[item sharingURL].absoluteString);
    [self.delegate menu:self didSelectItem:item];
}
@end

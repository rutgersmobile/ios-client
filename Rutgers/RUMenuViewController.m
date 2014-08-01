//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


#import "RUMenuViewController.h"
#import "RUChannelManager.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "RUMenuSectionHeaderView.h"
#import "RUMenuTableViewCell.h"


@interface RUMenuViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIView *paddingView;
@property (nonatomic) NSLayoutConstraint *paddingHeightContstraint;

@property NSArray *channels;
@property NSArray *webLinks;

@end

@implementation RUMenuViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.channels = [NSMutableArray array];
        self.title = @"Menu";
        }
    
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self makeSubviews];
    
    RUChannelManager *manager = [RUChannelManager sharedInstance];
    self.channels = [manager loadChannels];
    
    [manager loadWebLinksWithCompletion:^(NSArray *webLinks) {
        [self.tableView beginUpdates];
        self.webLinks = webLinks;
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
 //   self.tableView.separatorInset = UIEdgeInsetsZero;
    //self.tableView.separatorColor = [UIColor grey4Color];
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView registerClass:[RUMenuTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUMenuTableViewCell class])];
    [self.tableView registerClass:[RUMenuSectionHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([RUMenuSectionHeaderView class])];
}

-(void)makeSubviews{
    
    UIView *paddingView = [UIView newAutoLayoutView];
    [self.view addSubview:paddingView];
    self.paddingView = paddingView;
    self.paddingHeightContstraint = [paddingView autoSetDimension:ALDimensionHeight toSize:37.0];
    [paddingView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.opaque = YES;
    
    [self setLayoutForOrientation:self.interfaceOrientation];
    
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:paddingView];
}

-(void)setLayoutForOrientation:(UIInterfaceOrientation)orientation{
    [self.tableView beginUpdates];
    self.tableView.rowHeight = UIInterfaceOrientationIsPortrait(orientation) ? 56.0 : 48.0;
    self.paddingHeightContstraint.constant = UIInterfaceOrientationIsPortrait(orientation) ? 37.0 : 25.0;
    [self.tableView endUpdates];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RUMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RUMenuTableViewCell class])];
    cell.channelTitleLabel.text = [[self channelForIndexPath:indexPath] titleForChannel];
    cell.channelImage.image = [[self channelForIndexPath:indexPath] iconForChannel];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self titleForHeaderInSection:section];
}

/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    RUMenuSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([RUMenuSectionHeaderView class])];
    header.sectionTitleLabel.text = [[self titleForHeaderInSection:section] uppercaseString];
    return header;
}*/

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 27.0;
}
-(NSString *)titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Channels";
    } else {
        return @"Web Links";
    }
    return nil;
}

-(NSDictionary *)channelForIndexPath:(NSIndexPath *)indexPath{
    return [self channelsForSection:indexPath.section][indexPath.row];
}
-(NSArray *)channelsForSection:(NSInteger)section{
    if (section == 0) {
        return self.channels;
    } else if (section == 1) {
        return self.webLinks;
    }
    return nil;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self channelsForSection:section].count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.webLinks ? 2 : 1;
}

- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *channel = [self channelForIndexPath:indexPath];
    [self.delegate menu:self didSelectChannel:channel];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.paddingHeightContstraint.constant = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 37.0 : 25.0;
    [self setLayoutForOrientation:toInterfaceOrientation];
    [self.paddingView setNeedsUpdateConstraints];
}
@end

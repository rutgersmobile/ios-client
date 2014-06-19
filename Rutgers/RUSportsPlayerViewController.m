//
//  RUSportsPlayerViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsPlayerViewController.h"
#import "EZTableViewController.h"
#import "RUSportsPlayer.h"
#import <UIImageView+AFNetworking.h>
#import "EZTableViewMapsSection.h"
#import "EZTableViewRightDetailRow.h"

@interface RUSportsPlayerViewController ()
@property (nonatomic) UIImageView *playerImageView;
@property (nonatomic) EZTableViewController *tableController;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) RUSportsPlayer *player;
@end

@implementation RUSportsPlayerViewController
-(instancetype)initWithPlayer:(RUSportsPlayer *)player{
    self = [super init];
    if (self) {
        self.player = player;
        self.title = player.name;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.playerImageView = [[UIImageView alloc] initForAutoLayout];
    self.playerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.playerImageView.clipsToBounds = YES;
    [self.view addSubview:self.playerImageView];
    
    self.tableController = [[EZTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self addChildViewController:self.tableController];
    
    EZTableViewRightDetailRow *numberRow = [[EZTableViewRightDetailRow alloc] initWithText:self.player.jerseyNumber detailText:@"Jersey Number"];
    EZTableViewRightDetailRow *physiqueRow = [[EZTableViewRightDetailRow alloc] initWithText:self.player.physique detailText:@"Physique"];
    EZTableViewRightDetailRow *positionRow = [[EZTableViewRightDetailRow alloc] initWithText:self.player.position detailText:@"Position"];
    EZTableViewRightDetailRow *hometownRow = [[EZTableViewRightDetailRow alloc] initWithText:self.player.hometown detailText:@"Hometown"];
    EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:@"Stats" rows:@[numberRow,physiqueRow,positionRow,hometownRow]];
    [self.tableController addSection:section];
    
    self.tableView = self.tableController.tableView;

    [self.view addSubview:self.tableView];
    
    if (self.player.imageUrl) {
        [self.playerImageView setImageWithURL:self.player.imageUrl];
    }
    
    [self applyLayoutForInterfaceOrientation:self.interfaceOrientation];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)applyLayoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    [self.view autoRemoveConstraintsAffectingViewAndSubviews];
    [self.playerImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionWidth ofView:self.playerImageView withMultiplier:3.0/2.0];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [self.playerImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.playerImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
        [self.playerImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view withMultiplier:0.5];
        
        [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.playerImageView];
    } else {
        [self.playerImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeRight];
        
        [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
        [self.tableView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.playerImageView];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self applyLayoutForInterfaceOrientation:toInterfaceOrientation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  RUSportsRosterViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/10/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSportsRosterViewController.h"
#import "RUSportsPlayerCell.h"
#import "RUSportsPlayerRow.h"
#import "RUSportsData.h"
#import "EZTableViewSection.h"
#import "RUSportsPlayer.h"
#import "RUSportsRosterSectionHeaderView.h"
#import "RUSportsRosterPlayerHeaderCell.h"

@interface RUSportsRosterViewController ()
@property NSString *sportID;

@property EZTableViewSection *headerSection;
@property EZTableViewSection *bioSection;
@property EZTableViewSection *rosterSection;

@property NSInteger selectedPlayerIndex;
@property NSArray *players;
@end

@implementation RUSportsRosterViewController

-(id)initWithSportID:(NSString *)sportID{
    self = [super init];
    if (self) {
        self.sportID = sportID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerClass:[RUSportsRosterSectionHeaderView class] forHeaderFooterViewReuseIdentifier:@"HeaderView"];
    [self startNetworkLoad];
}

-(void)startNetworkLoad{
    [RUSportsData getRosterForSportID:self.sportID withSuccess:^(NSArray *response) {
        self.players = response;
        [self makeRosterSection];
        [self networkLoadSucceeded];
    } failure:^{
        [self networkLoadFailed];
    }];
}

-(void)makeRosterSection{
    EZTableViewSection *rosterSection = [[EZTableViewSection alloc] initWithSectionTitle:@"Roster"];
    for (RUSportsPlayer *player in self.players) {
        RUSportsPlayerRow *playerRow = [[RUSportsPlayerRow alloc] initWithPlayer:player];
        playerRow.showsDisclosureIndicator = NO;
        playerRow.didSelectRowBlock = ^{
            [self selectPlayerAtIndex:[self.players indexOfObject:player]];
        };
        [rosterSection addRow:playerRow];
    }
    [self addSection:rosterSection];
    self.rosterSection = rosterSection;
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self indexOfRosterSection]] withRowAnimation:UITableViewRowAnimationFade];
}

-(NSInteger)indexOfRosterSection{
    return [self.sections indexOfObject:self.rosterSection];
}

-(void)selectPlayerAtIndex:(NSInteger)index{
    UIView *playerHeaderView = [[RUSportsRosterPlayerHeaderCell alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 118)];
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = playerHeaderView;
    [self.tableView endUpdates];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *title = [super tableView:tableView titleForHeaderInSection:section];
    RUSportsRosterSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeaderView"];
    headerView.sectionHeaderLabel.text = title;
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 38;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

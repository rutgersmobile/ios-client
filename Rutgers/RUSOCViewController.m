//
//  RUSOCViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCViewController.h"
#import "RUSOCData.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"
#import "ALTableViewRightDetailCell.h"
#import "RUSOCSubjectViewController.h"
#import "RUSOCOptionsViewController.h"

@interface RUSOCViewController () <UISearchDisplayDelegate, RUSOCOptionsDelegate>
@property (nonatomic) UIBarButtonItem *optionsButton;
@property BOOL optionsDidChange;
@property RUSOCData *socData;
@end

@implementation RUSOCViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUSOCViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.socData = [RUSOCData sharedInstance];

    [self enableSearch];
    [self setupOptionsButton];
    
    
    [self setupContentLoadingStateMachine];
    
    [self.socData loadSemestersWithCompletion:^{
        self.title = self.socData.titleForCurrentConfiguration;
        self.optionsButton.enabled = YES;
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.optionsDidChange) {
        [self.dataSource removeAllSections];
        self.contentLoadingStateMachine.contentLoaded = NO;
        [self.contentLoadingStateMachine startNetworking];
        self.optionsDidChange = NO;
    }
}

-(void)loadNetworkData{
    [[RUSOCData sharedInstance] getSubjectsWithSuccess:^(NSArray *subjects) {
        [self.contentLoadingStateMachine networkLoadSuccessful];
        [self.tableView beginUpdates];
        [self makeSectionsForResponse:subjects];
        [self.tableView endUpdates];
    } failure:^{
        [self.contentLoadingStateMachine networkLoadFailedWithParsingError];
    }];
}

-(void)makeSectionsForResponse:(NSArray *)response{
    EZDataSourceSection *section = [[EZDataSourceSection alloc] initWithSectionTitle:@"Subjects"];
    for (NSDictionary *subject in response) {
        NSString *subjectTitle = [NSString stringWithFormat:@"%@ (%@)",[subject[@"description"] capitalizedString],subject[@"code"]];
        EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:subjectTitle];
        row.didSelectRowBlock = ^{
            [self.navigationController pushViewController:[[RUSOCSubjectViewController alloc] initWithSubject:subjectTitle code:subject[@"code"]] animated:YES];
        };
        [section addItem:row];
    }
    [self.dataSource addSection:section];
}

-(void)setupOptionsButton{
    self.optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.optionsButton;
    self.optionsButton.enabled = NO;
}

-(void)optionsButtonPressed{
    [self.navigationController pushViewController:[[RUSOCOptionsViewController alloc] initWithDelegate:self] animated:YES];
}

-(void)optionsViewControllerDidChangeOptions:(RUSOCOptionsViewController *)optionsViewController{
    self.optionsDidChange = YES;
    self.title = self.socData.titleForCurrentConfiguration;
}




@end

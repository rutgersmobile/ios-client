//
//  RUSOCViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCViewController.h"
#import "RUSOCData.h"
#import "EZTableViewSection.h"
#import "EZTableViewRow.h"
#import "RUSOCSubjectViewController.h"

@interface RUSOCViewController () <UISearchDisplayDelegate>
@property UISearchDisplayController *searchController;
@end

@implementation RUSOCViewController
+(instancetype)component{
    return [[RUSOCViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSearchController];
    [[RUSOCData sharedInstance] getSubjectsForCurrentSemesterWithCompletion:^(NSArray *subjects) {
        EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:@"Subjects"];
        for (NSDictionary *subject in subjects) {
            NSString *subjectTitle = [NSString stringWithFormat:@"%@ (%@)",[subject[@"description"] capitalizedString],subject[@"code"]];
            EZTableViewRow *row = [[EZTableViewRow alloc] initWithText:subjectTitle];
            row.didSelectRowBlock = ^{
                [self.navigationController pushViewController:[[RUSOCSubjectViewController alloc] initWithSubject:subjectTitle code:subject[@"code"]] animated:YES];
            };
            [section addRow:row];
        }
        [self addSection:section];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }];
    // Do any additional setup after loading the view.
}

-(void)setupSearchController{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ALTableViewRightDetailCell"];
    
    self.tableView.tableHeaderView = searchBar;
}


@end

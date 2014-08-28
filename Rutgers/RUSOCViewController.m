//
//  RUSOCViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCViewController.h"
#import "RUSOCDataSource.h"
#import "RUSOCSearchDataSource.h"
#import "RUSOCSubjectViewController.h"
#import "RUSOCCourseViewController.h"
#import "RUSOCOptionsViewController.h"
#import "RUSOCDataLoadingManager.h"
#import "DataTuple.h"

@interface RUSOCViewController () <UISearchDisplayDelegate, RUSOCOptionsDelegate>
@property (nonatomic) UIBarButtonItem *optionsButton;
@property BOOL optionsDidChange;
@end

@implementation RUSOCViewController
+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[RUSOCViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonPressed)];
    
    self.dataSource = [[RUSOCDataSource alloc] init];
    self.searchDataSource = [[RUSOCSearchDataSource alloc] init];
    self.searchBar.placeholder = @"Search Subjects and Courses";
    
    [((RUSOCSearchDataSource *)self.searchDataSource) setNeedsLoadIndex];
    
    [self disableInterface];
    
    RUSOCDataLoadingManager *loadingManager = [RUSOCDataLoadingManager sharedInstance];
    [loadingManager performOnSemestersLoaded:^{
        self.title = loadingManager.titleForCurrentConfiguration;
        [self enableInterface];
    }];

}

-(void)disableInterface{
    self.optionsButton.enabled = NO;
    self.searchBar.userInteractionEnabled = NO;
    self.searchBar.alpha = 0.4;
}

-(void)enableInterface{
    self.optionsButton.enabled = YES;
    self.searchBar.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.15 animations:^{
        self.searchBar.alpha = 1.0;
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.optionsDidChange) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.optionsDidChange) {
        [self.dataSource resetContent];
        [self.dataSource setNeedsLoadContent];
        
        [((RUSOCSearchDataSource *)self.searchDataSource) setNeedsLoadIndex];
        
        self.optionsDidChange = NO;
    }
}
 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *item = [[self dataSourceForTableView:tableView] itemAtIndexPath:indexPath];
   
    if (item.object[@"courseNumber"]) {
        RUSOCCourseViewController *courseVC = [[RUSOCCourseViewController alloc] initWithCourse:item.object];
        [self.navigationController pushViewController:courseVC animated:YES];
    } else {
        RUSOCSubjectViewController *subjectVC = [[RUSOCSubjectViewController alloc] initWithSubject:item.object];
        [self.navigationController pushViewController:subjectVC animated:YES];
    }
}

-(void)optionsButtonPressed{
    [self.navigationController pushViewController:[[RUSOCOptionsViewController alloc] initWithDelegate:self] animated:YES];
}

-(void)optionsViewControllerDidChangeOptions:(RUSOCOptionsViewController *)optionsViewController{
    self.optionsDidChange = YES;
    self.title = [RUSOCDataLoadingManager sharedInstance].titleForCurrentConfiguration;
}

@end

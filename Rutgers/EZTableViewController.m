//
//  EZTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewController.h"
#import "EZDataSource.h"
#import "EZDataSourceSection.h"

@interface EZTableViewController ()
@property (nonatomic) NSMutableArray *searchResultSections;
@property (nonatomic) BOOL searchEnabled;
@property (nonatomic) UITableViewStyle style;
@property (nonatomic) EZDataSource *dataSource;
@end

@implementation EZTableViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.searchResultSections = [NSMutableArray array];
        self.dataSource = [[EZDataSource alloc] init];
        self.dataSource.delegate = self;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

-(void)setupContentLoadingStateMachine{
    [self performSelector:@selector(loadNetworkData)];
    /*
    NetworkContentStateIndicatorView *indicatorView = [[NetworkContentStateIndicatorView alloc] initForAutoLayout];
    [self.view addSubview:indicatorView];
    [indicatorView autoCenterInSuperview];
    
    self.contentLoadingStateMachine = [[NetworkContentLoadingStateMachine alloc] initWithStateIndicatorView:indicatorView];
    
    // self.refreshControl = [[UIRefreshControl alloc] init];
    self.contentLoadingStateMachine.refreshControl =  self.refreshControl;
    self.contentLoadingStateMachine.delegate = self;
    [self.contentLoadingStateMachine startNetworking];*/
}


-(void)enableSearch{
    if (self.searchEnabled) return;
    /*
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [RUAppearance applyAppearanceToSearchBar:searchBar];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    self.searchController.searchResultsTableView.estimatedRowHeight = 44.0;
    
    self.tableView.tableHeaderView = searchBar;
    
    self.searchEnabled = YES;*/
}

/*

#pragma mark - SearchDisplayController Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterForSearchString:searchString];
    return YES;
}

-(void)filterForSearchString:(NSString *)string{
    @synchronized (self.searchResultSections) {
        [self.searchResultSections removeAllObjects];
        for (EZDataSourceSection *section in self.sections) {
            NSArray *filteredRows = [section.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EZTableViewAbstractRow *row, NSDictionary *bindings) {
                NSString *text = row.textRepresentation;
                return ([text rangeOfString:string options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound);
            }]];
            if (filteredRows.count) {
                EZDataSourceSection *filteredSection = [[EZDataSourceSection alloc] initWithSectionTitle:section.title rows:filteredRows];
                [self.searchResultSections addObject:filteredSection];
            }
        }
    }
}*/

@end

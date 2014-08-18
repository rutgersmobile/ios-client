//
//  ALTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewController.h"
#import "ALTableViewRightDetailCell.h"
#import "ALTableViewTextCell.h"
#import "UIView+LayoutSize.h"

@interface ALTableViewController () 
@property (nonatomic) NSMutableDictionary *layoutCells;
@property (nonatomic) BOOL searchEnabled;
@property (nonatomic) UITableViewStyle style;
@end

@implementation ALTableViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.layoutCells = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.style = style;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.style];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    
    [self.view addSubview:tableView];
    [tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

-(void)viewDidLoad{
    [super viewDidLoad];

    self.tableView.estimatedRowHeight = 44.0;
}

-(void)enableSearch{
    if (self.searchEnabled) return;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [RUAppearance applyAppearanceToSearchBar:searchBar];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    self.searchController.searchResultsTableView.estimatedRowHeight = 44.0;
    
    self.tableView.tableHeaderView = searchBar;
    
    self.searchEnabled = YES;
}
/*
-(void)setupContentLoadingStateMachine{
    NetworkContentStateIndicatorView *indicatorView = [[NetworkContentStateIndicatorView alloc] initForAutoLayout];
    [self.view addSubview:indicatorView];
    [indicatorView autoCenterInSuperview];
    
    self.contentLoadingStateMachine = [[NetworkContentLoadingStateMachine alloc] initWithStateIndicatorView:indicatorView];
    
   // self.refreshControl = [[UIRefreshControl alloc] init];
    self.contentLoadingStateMachine.refreshControl =  self.refreshControl;
    self.contentLoadingStateMachine.delegate = self;
    [self.contentLoadingStateMachine startNetworking];
}*/

-(void)setRefreshControl:(UIRefreshControl *)refreshControl{
    _refreshControl = refreshControl;
    [_refreshControl removeFromSuperview];
    [self.tableView addSubview:refreshControl];
}


-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark - Table view data source
-(id)layoutViewWithIdentifier:(NSString *)identifier{
    UIView *layoutView = self.layoutCells[identifier];
    if (!layoutView) {
        Class viewClass = NSClassFromString(identifier);
        if ([viewClass isSubclassOfClass:[UITableViewCell class]]) {
            layoutView = [[viewClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        } else if ([viewClass isSubclassOfClass:[UITableViewHeaderFooterView class]]) {
            layoutView = [[viewClass alloc] initWithReuseIdentifier:identifier];
        } else {
            [NSException raise:@"identifier is not a table cell or section header" format:nil];
        }
        self.layoutCells[identifier] = layoutView;
    }
    return layoutView;
}

-(NSString *)identifierForCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([UITableViewCell class]);
}

-(NSString *)identifierForHeaderInTableView:(UITableView *)tableView inSection:(NSInteger)section{
    return NSStringFromClass([UITableViewHeaderFooterView class]);
}

-(BOOL)tableView:(UITableView *)tableView sectionHasCustomHeader:(NSInteger)section{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [self identifierForCellInTableView:tableView atIndexPath:indexPath];
    ALTableViewAbstractCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        [tableView registerClass:NSClassFromString(identifier) forCellReuseIdentifier:identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    [self setupCell:cell inTableView:tableView forRowAtIndexPath:indexPath];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *identifier = [self identifierForHeaderInTableView:tableView inSection:section];
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
   
    if (!view) {
        [tableView registerClass:NSClassFromString(identifier) forHeaderFooterViewReuseIdentifier:identifier];
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    }
    
    [self setupHeader:view inTableView:tableView inSection:section];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *layoutCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGSize fittingSize = [layoutCell layoutSizeFittingSize:tableView.bounds.size];
    [layoutCell removeFromSuperview];
    return fittingSize.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (![self tableView:tableView sectionHasCustomHeader:section]) return UITableViewAutomaticDimension;

    NSString *identifier = [self identifierForHeaderInTableView:tableView inSection:section];
    UITableViewHeaderFooterView *layoutView = [self layoutViewWithIdentifier:identifier];
    [self setupHeader:layoutView inTableView:tableView inSection:section];
    [layoutView setNeedsUpdateConstraints];
    [layoutView updateConstraintsIfNeeded];
    
    return [layoutView layoutSizeFittingSize:tableView.bounds.size].height;
}

-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    [NSException raise:@"Must override abstract methods in ALTableview" format:nil];
}

-(void)setupHeader:(UITableViewHeaderFooterView *)header inTableView:(UITableView *)tableView inSection:(NSInteger)section{
     
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

@end

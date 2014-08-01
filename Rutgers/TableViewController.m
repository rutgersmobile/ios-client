//
//  TableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/1/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "TableViewController.h"
#import "DataSource_Private.h"

@interface TableViewController () <UISearchDisplayDelegate, DataSourceDelegate>
@property (nonatomic) DataSource *dataSource;
@property (nonatomic) DataSource<SearchDataSource> *searchDataSource;
@property (nonatomic) BOOL searchEnabled;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) dispatch_group_t searchingGroup;
@property (nonatomic) BOOL loadsContentOnViewWillAppear;
@end

@implementation TableViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.searchingGroup = dispatch_group_create();
    self.loadsContentOnViewWillAppear = YES;
    self.tableView.estimatedRowHeight = 44.0;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.loadsContentOnViewWillAppear || [self.dataSource.loadingState isEqualToString:AAPLLoadStateInitial]) {
        [self.dataSource setNeedsLoadContent];
    }
}

#pragma mark - Data Source
@synthesize dataSource = _dataSource;
-(DataSource *)dataSource{
    return _dataSource;
}

-(void)setDataSource:(DataSource *)dataSource{
    _dataSource.delegate = nil;
    _dataSource = dataSource;
    dataSource.delegate = self;
    [self setupTableView:self.tableView withDataSource:dataSource];
}

#pragma mark - Search Data Source
@synthesize searchDataSource = _searchDataSource;
-(DataSource<SearchDataSource> *)searchDataSource{
    return _searchDataSource;
}

-(void)setSearchDataSource:(DataSource<SearchDataSource> *)searchDataSource{
    if (searchDataSource && !self.searchEnabled) {
        [self enableSearch];
    }
    
    if (!_searchDataSource && searchDataSource) {
        self.tableView.tableHeaderView = self.searchBar;
    }
    
    if (_searchDataSource && !searchDataSource) {
        [self.searchBar removeFromSuperview];
    }
    
    _searchDataSource.delegate = nil;
    _searchDataSource = searchDataSource;
    searchDataSource.delegate = self;
    [self setupTableView:self.searchTableView withDataSource:searchDataSource];
}

-(void)enableSearch{
     self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
     [RUAppearance applyAppearanceToSearchBar:self.searchBar];
     
     self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
     self.searchController.searchResultsDelegate = self;
     self.searchController.delegate = self;
     self.searchController.searchResultsTableView.estimatedRowHeight = 44.0;
    
     self.searchEnabled = YES;
}

-(void)setupTableView:(UITableView *)tableView withDataSource:(DataSource *)dataSource{
    tableView.dataSource = dataSource;
    [dataSource registerReusableViewsWithTableView:tableView];
    [tableView reloadData];
}

-(UITableView *)searchTableView{
    return self.searchController.searchResultsTableView;
}
 
 #pragma mark - SearchDisplayController Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self.searchDataSource updateForSearchString:searchString];
    return NO;
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    dispatch_group_enter(self.searchingGroup);
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    dispatch_group_leave(self.searchingGroup);
}

#pragma mark - TableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        return [self.dataSource tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return [self.searchDataSource tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


#pragma mark - Data Source notifications
-(UITableViewRowAnimation)rowAnimationForSectionOperationDirection:(DataSourceOperationDirection)direction{
    switch (direction) {
        case DataSourceOperationDirectionNone:
            return UITableViewRowAnimationAutomatic;
            break;
        case DataSourceOperationDirectionLeft:
            return UITableViewRowAnimationLeft;
            break;
        case DataSourceOperationDirectionRight:
            return UITableViewRowAnimationRight;
            break;
    }
}

-(void)dataSource:(DataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)insertedIndexPaths{
    if (dataSource == self.dataSource) {
        [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)dataSource:(DataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)removedIndexPaths{
    if (dataSource == self.dataSource) {
        [self.tableView deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)dataSource:(DataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)refreshedIndexPaths{
    if (dataSource == self.dataSource) {
        [self.tableView reloadRowsAtIndexPaths:refreshedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView reloadRowsAtIndexPaths:refreshedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)dataSource:(DataSource *)dataSource didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath{
    if (dataSource == self.dataSource) {
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

-(void)dataSource:(DataSource *)dataSource didRefreshSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    if (dataSource == self.dataSource) {
        [self.tableView reloadSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView reloadSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
    }
}

-(void)dataSource:(DataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    if (dataSource == self.dataSource) {
        [self.tableView insertSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView insertSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
    }
}

-(void)dataSource:(DataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(DataSourceOperationDirection)direction{
    if (dataSource == self.dataSource) {
        [self.tableView deleteSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView deleteSections:sections withRowAnimation:[self rowAnimationForSectionOperationDirection:direction]];
    }
}

-(void)dataSource:(DataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection direction:(DataSourceOperationDirection)direction{
    if (dataSource == self.dataSource) {
        [self.tableView moveSection:section toSection:newSection];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView moveSection:section toSection:newSection];
    }
}

-(void)dataSourceDidReloadData:(DataSource *)dataSource{
    if (dataSource == self.dataSource) {
        [self.tableView reloadData];
    } else if (dataSource == self.searchDataSource){
        [self.searchTableView reloadData];
    }
}

-(void)dataSource:(DataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete{
    
    void(^updateTable)(UITableView *tableView) = ^(UITableView *tableView){
        [tableView beginUpdates];
        if (update) {
            update();
        }
        [tableView endUpdates];
        
        if (complete) {
            complete();
        }
    };
    
    if (dataSource == self.dataSource) {
        [self performWhenNotSearching:^{
            updateTable(self.tableView);
        }];
    } else if (dataSource == self.searchDataSource){
        updateTable(self.searchTableView);
    }

}

-(void)dataSourceWillLoadContent:(DataSource *)dataSource{
    
}

-(void)dataSource:(DataSource *)dataSource didLoadContentWithError:(NSError *)error{
    
}

-(void)performWhenNotSearching:(dispatch_block_t)block{
    dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), block);
}

@end

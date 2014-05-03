//
//  RUPlacesTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUPlacesTableViewController.h"
#import "RUPlacesData.h"
#import "RUPlaceDetailTableViewController.h"


NSString *const placesSavedSearchTextKey = @"placesSavedSearchTextKey";

@interface RUPlacesTableViewController () <UISearchDisplayDelegate>
@property (nonatomic) RUPlacesData *placesData;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UISearchDisplayController *searchController;
@property NSArray *searchResults;
@property NSArray *recentSearches;
@end

@implementation RUPlacesTableViewController
-(id)initWithDelegate:(id<RUComponentDelegate>)delegate{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.delegate = delegate;
        self.placesData = [RUPlacesData sharedInstance];
        self.navigationItem.title = @"Places";
        
        // Custom initialization
        if ([self.delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
            // delegate expects menu button notification, so let's create and add a menu button
            UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
            self.navigationItem.leftBarButtonItem = btn;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.showsCancelButton = YES;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.delegate = self;
    
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    
    self.tableView.tableHeaderView = self.searchBar;
    
    [self.placesData getRecentPlacesWithCompletion:^(NSArray *recents) {
        self.recentSearches = recents;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    /*
    NSString *searchText = [[NSUserDefaults standardUserDefaults] stringForKey:placesSavedSearchTextKey];
    self.searchBar.text = searchText;
    [self queryText:searchText];
    */

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearResponders) name:@"JASidePanelWillShowLeftPanel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearResponders) name:@"JASidePanelDidBeginPanning" object:nil];
    
  
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self.placesData queryPlacesWithString:searchString completion:^(NSArray *results) {
        self.searchResults = results;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    return NO;
}
-(void)clearResponders{
    [self.searchBar resignFirstResponder];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self clearResponders];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self clearResponders];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return self.recentSearches.count;
    } else if (tableView == self.searchController.searchResultsTableView) {
        return self.searchResults.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSDictionary *itemForCell;

    if (tableView == self.tableView) {
        itemForCell = self.recentSearches[indexPath.row];
    } else if (tableView == self.searchController.searchResultsTableView) {
        itemForCell = self.searchResults[indexPath.row];

    }
    cell.textLabel.text = itemForCell[@"title"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *itemForCell;

    if (tableView == self.tableView) {
        itemForCell = self.recentSearches[indexPath.row];

    } else if (tableView == self.searchController.searchResultsTableView) {
        itemForCell = self.searchResults[indexPath.row];
        [self.placesData userDidSelectPlace:itemForCell];
        [self.placesData getRecentPlacesWithCompletion:^(NSArray *recents) {
            self.recentSearches = recents;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }

    RUPlaceDetailTableViewController *detailVC = [[RUPlaceDetailTableViewController alloc] initWithPlace:itemForCell];
    [self.navigationController pushViewController:detailVC animated:YES];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (tableView == self.tableView) {
        return @"Recent Places";
    } else if (tableView == self.searchController.searchResultsTableView) {
        return @"Search Results";
    }
    return nil;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

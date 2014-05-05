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
#import "RULocationManager.h"

NSString *const placesSavedSearchTextKey = @"placesSavedSearchTextKey";

@interface RUPlacesTableViewController () <UISearchDisplayDelegate, RULocationManagerDelegate>
@property (nonatomic) RUPlacesData *placesData;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UISearchDisplayController *searchController;
@property dispatch_group_t searchingGroup;
@property NSArray *nearbyPlaces;
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
        self.searchingGroup = dispatch_group_create();
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
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    
    [self.searchController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.tableHeaderView = self.searchBar;
    
    NSString *searchText = [[NSUserDefaults standardUserDefaults] stringForKey:placesSavedSearchTextKey];
    self.searchBar.text = searchText;
    //[self queryText:searchText];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearResponders) name:@"JASidePanelWillShowLeftPanel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearResponders) name:@"JASidePanelDidBeginPanning" object:nil];
    
  
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)locationManager:(RULocationManager *)manager didUpdateLocation:(CLLocation *)location{
    dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
        [self.placesData placesNearLocation:location completion:^(NSArray *nearbyPlaces) {
            [self.tableView beginUpdates];
            self.nearbyPlaces = nearbyPlaces;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }];
    });
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[RULocationManager sharedLocationManager] addDelegatesObject:self];
    [self.placesData getRecentPlacesWithCompletion:^(NSArray *recents) {
        dispatch_group_notify(self.searchingGroup, dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            self.recentSearches = recents;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        });
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[RULocationManager sharedLocationManager] removeDelegatesObject:self];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - search display controller
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self.placesData queryPlacesWithString:searchString completion:^(NSArray *results) {
        self.searchResults = results;
        [self.searchController.searchResultsTableView reloadData];
    }];
    return NO;
}
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    dispatch_group_enter(self.searchingGroup);
}
-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    dispatch_group_leave(self.searchingGroup);
}
/*
-(void)indexPathsForAdding:(NSInteger)number{
    
}
-(void)indexPathsForRemoving:(NSInteger)number fromCountOf:(NSInteger)count{
    
}*/
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
    if (tableView == self.tableView) {
        return 2;
    } else if (tableView == self.searchController.searchResultsTableView) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return self.nearbyPlaces.count;
                break;
            case 1:
                return self.recentSearches.count;
                break;
            default:
                break;
        }
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
        switch (indexPath.section) {
            case 0:
                itemForCell = self.nearbyPlaces[indexPath.row];
                break;
            case 1:
                itemForCell = self.recentSearches[indexPath.row];
                break;
            default:
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        itemForCell = self.searchResults[indexPath.row];

    }
    cell.textLabel.text = itemForCell[@"title"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *itemForCell;

    if (tableView == self.tableView) {
        switch (indexPath.section) {
            case 0:
                itemForCell = self.nearbyPlaces[indexPath.row];
                [self.placesData addPlaceToRecentPlacesList:itemForCell];
                break;
            case 1:
                itemForCell = self.recentSearches[indexPath.row];
                break;
            default:
                break;
        }
    } else if (tableView == self.searchController.searchResultsTableView) {
        itemForCell = self.searchResults[indexPath.row];
        [self.placesData addPlaceToRecentPlacesList:itemForCell];
    }

    RUPlaceDetailTableViewController *detailVC = [[RUPlaceDetailTableViewController alloc] initWithPlace:itemForCell];
    [self.navigationController pushViewController:detailVC animated:YES];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return @"Nearby Places";
                break;
            case 1:
                return @"Recently Viewed";
                break;
            default:
                break;
        }
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

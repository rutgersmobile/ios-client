//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


#import "RUMenuViewController.h"
#import "RUChannelManager.h"
#import <JASidePanelController.h>

@interface RUMenuViewController () <UISearchDisplayDelegate, RUChannelManagerDelegate>
@property (nonatomic) UISearchDisplayController *searchController;
@property NSMutableArray *channels;
@end

@implementation RUMenuViewController
-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.channels = [NSMutableArray array];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
      //  [self setupSearchController];
        self.title = @"Channels";
        RUChannelManager *manager = [RUChannelManager sharedInstance];
        manager.delegate = self;
        [manager loadChannels];
        
    }
    return self;
}

-(void)loadedNewChannels:(NSArray *)newChannels{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[self indexPathsForRange:NSMakeRange(self.channels.count, newChannels.count) inSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.channels addObjectsFromArray:newChannels];
    [self.tableView endUpdates];
}

-(NSArray *)indexPathsForRange:(NSRange)range inSection:(NSInteger)section{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:range.length];
    for (NSUInteger i = range.location; i < (range.location + range.length); i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    return indexPaths;
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

-(NSDictionary *)channelForIndexPath:(NSIndexPath *)indexPath{
    return self.channels[indexPath.row];
}

- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *channel = [self channelForIndexPath:indexPath];
 //   [tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self.delegate menu:self didSelectChannel:channel];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[self channelForIndexPath:indexPath] titleForChannel];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channels.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return 1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

@end

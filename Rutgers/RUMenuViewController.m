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
#import <UIViewController+JASidePanel.h>
#import "RUMenuSectionHeaderView.h"
#import "RUMenuTableViewCell.h"

@interface RUMenuViewController () <UISearchDisplayDelegate, RUChannelManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UITableView *tableView;

@property NSMutableArray *channels;
@end

@implementation RUMenuViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.channels = [NSMutableArray array];
        
        //self.title = @"Channels";
        RUChannelManager *manager = [RUChannelManager sharedInstance];
        manager.delegate = self;
        [manager loadChannels];

        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillDisappear:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillAppear:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];*/
    }
    
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self makeSubviews];
    
    
    self.view.backgroundColor = [UIColor grey2Color];
    self.tableView.backgroundColor = [UIColor grey2Color];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor grey4Color];
    
    
    [self.tableView registerClass:[RUMenuTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[RUMenuSectionHeaderView class] forHeaderFooterViewReuseIdentifier:@"Header"];
}

-(void)makeSubviews{
   // CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    
    UIView *paddingView = [[UIView alloc] initForAutoLayout];
    [self.view addSubview:paddingView];
    [paddingView autoSetDimension:ALDimensionHeight toSize:37.0];
    [paddingView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];


    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.opaque = YES;
    
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:paddingView];
    
}/*
-(void)makeSearchbar{
    self.searchBar = [[UISearchBar alloc] initForAutoLayout];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.searchBar setTintColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.searchBar];
    
    [self.searchBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]), 0, 0, 0) excludingEdge:ALEdgeBottom];
    self.searchBar.translucent = NO;
    self.searchBar.clipsToBounds = YES;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
}
-(void)makeHeader{
    
     RUMenuTableHeaderView *headerView = [[RUMenuTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), MENU_HEADER_IMAGE_HEIGHT+16)];
     headerView.backgroundColor = [UIColor grey1Color];
     headerView.imageView.image = [UIImage imageNamed:@"IMG_3713.jpg"];
     headerView.nameLabel.text = @"John Smith";
     headerView.detailLabel.text = @"Undergraduate Class of '14";
     
     self.tableView.tableHeaderView = headerView;
}*/
  
/*
- (void)keyboardWillAppear:(NSNotification *)note
{
    [self.sidePanelController setCenterPanelHidden:YES
                                          animated:YES
                                          duration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [self.searchBar setShowsCancelButton:YES animated:NO];
}

- (void)keyboardWillDisappear:(NSNotification *)note
{
    [self.searchBar setShowsCancelButton:NO animated:NO];
    
    [self.sidePanelController setCenterPanelHidden:NO
                                          animated:YES
                                          duration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
}
*/

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

-(NSDictionary *)channelForIndexPath:(NSIndexPath *)indexPath{
    return self.channels[indexPath.row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RUMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.channelTitleLabel.text = [[self channelForIndexPath:indexPath] titleForChannel];
    cell.channelImage.image = [[self channelForIndexPath:indexPath] iconForChannel];
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    RUMenuSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    header.sectionTitleLabel.text = [self titleForHeaderInSection:section];
    return header;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 27.0;
}
-(NSString *)titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"CHANNELS";
    }
    return nil;
}/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Channels";
    }
    return nil;
}*/
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
    return 56;
}
- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *channel = [self channelForIndexPath:indexPath];
    [self.delegate menu:self didSelectChannel:channel];
    
}
@end

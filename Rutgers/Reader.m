//
//  RUReaderController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "Reader.h"
#import <AFNetworking.h>
#import "RUReaderTableViewCell.h"
#import <TOWebViewController.h>
#import "RUNetworkManager.h"
#import "RUChannelManager.h"

@interface Reader ()
@property (nonatomic) NSArray *items;
@property (nonatomic) NSDictionary *channel;
@end

@implementation Reader
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[Reader alloc] initWithChannel:channel];
}

-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.rowHeight = 80.0;
    }
    return self;
}

-(id)initWithChannel:(NSDictionary *)channel{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        self.channel = channel;
        self.title = [channel titleForChannel];
        [self fetchDataForChannel];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RUReaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"ReaderCell"];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl beginRefreshing];
    [self.refreshControl addTarget:self action:@selector(fetchDataForChannel) forControlEvents:UIControlEventValueChanged];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}
-(void)fetchDataForChannel{
    [[RUNetworkManager xmlSessionManager] GET:self.channel[@"url"] parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *channel = [responseObject[@"channel"] firstObject];
            self.items = channel[@"item"];
            [self.refreshControl endRefreshing];
        } else {
            [self fetchDataForChannel];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self fetchDataForChannel];
    }];
}

-(void)setItems:(NSArray *)items{
    _items = items;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RUReaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReaderCell" forIndexPath:indexPath];
    NSDictionary *item = self.items[indexPath.row];
    cell.titleLabel.text = [item[@"title"] firstObject];
    cell.detailLabel.text = [item[@"description"] firstObject];
    cell.timeLabel.text = [item[@"pubDate"] firstObject];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = self.items[indexPath.row];
    NSString *link = [item[@"link"] firstObject];
    if (link) {
        TOWebViewController *webBrowser = [[TOWebViewController alloc] initWithURLString:link];
        webBrowser.title = [item[@"title"] firstObject];
        [self.navigationController pushViewController:webBrowser animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = self.items[indexPath.row];
    
    NSString *title = [item[@"title"] firstObject];
    NSString *description = [item[@"description"] firstObject];
    NSString *time = [item[@"pubDate"] firstObject];

    static NSDictionary *titleStringAttributes = nil;
    static NSDictionary *descriptionStringAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titleStringAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
        descriptionStringAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14] };
    });
    
    CGFloat width = self.view.bounds.size.width-30-26;
    CGSize titleStringSize = [title boundingRectWithSize:CGSizeMake(width, 9999)
                                                       options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:titleStringAttributes context:nil].size;
    
    CGSize descriptionStringSize = [description boundingRectWithSize:CGSizeMake(width, 9999)
                                                  options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                               attributes:descriptionStringAttributes context:nil].size;
    

    
    CGFloat height = round(20 + descriptionStringSize.height + titleStringSize.height);
    if (time) height += 20;
    return height;
}
@end

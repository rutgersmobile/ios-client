//
//  DynamicTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "dtable.h"
#import "Reader.h"
#import "RUNetworkManager.h"
#import "RUChannelManager.h"

@interface dtable ()
@property NSArray *children;
@property NSString *url;
@end

@implementation dtable
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[dtable alloc] initWithChannel:channel];
}

-(instancetype)initWithChannel:(NSDictionary *)channel{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.url = channel[@"url"];
        self.title = channel[@"title"];
        [self fetchData];
    }
    return self;
}
-(instancetype)initWithChildren:(NSArray *)children{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.children = children;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RUReaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"ReaderCell"];
   
}

-(void)fetchData{
    [[RUNetworkManager jsonSessionManager] GET:self.url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            self.children = responseObject[@"children"];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self fetchData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self fetchData];
    }];
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.children.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = nil;
    id child = self.children[indexPath.row];
    if ([child isKindOfClass:[NSDictionary class]]) {
        cell.textLabel.text = [self titleForChild:child];
    }
    if (child[@"channel"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (child[@"children"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
-(NSString *)titleForChild:(NSDictionary *)child{
    id title = child[@"title"];
    if ([title isKindOfClass:[NSString class]]) {
        return title = title;
    } else if ([title isKindOfClass:[NSDictionary class]]) {
        id subtitle = title[@"homeTitle"];
        if ([subtitle isKindOfClass:[NSString class]]) {
            return subtitle;
        }
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *child = self.children[indexPath.row];
    if (child[@"children"]) {
        dtable *dtvc = [[dtable alloc] initWithChildren:child[@"children"]];
        dtvc.title = [self titleForChild:child];
        [self.navigationController pushViewController:dtvc animated:YES];
    } else if (child[@"channel"]) {
        UIViewController * vc = [[RUChannelManager sharedInstance] viewControllerForChannel:child[@"channel"] delegate:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end

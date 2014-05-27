//
//  DynamicTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 4/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "dtable.h"
#import "Reader.h"
#import "RUChannelManager.h"
#import "RUNetworkManager.h"
#import "NSDictionary+Channel.h"
#import "EZTableViewSection.h"
#import "EZTableViewRow.h"

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
        [self makeSection];
    }
    return self;
}
-(void)makeSection{
    EZTableViewSection *section = [[EZTableViewSection alloc] init];
    for (NSDictionary *child in self.children) {
        NSString *title = [child titleForChannel];
        EZTableViewRow *row = [[EZTableViewRow alloc] initWithText:title];
        
        if (child[@"children"]) {
            row.didSelectRowBlock = ^{
                dtable *dtvc = [[dtable alloc] initWithChildren:child[@"children"]];
                dtvc.title = [child titleForChannel];
                [self.navigationController pushViewController:dtvc animated:YES];
            };
        } else if (child[@"channel"]) {
            row.didSelectRowBlock = ^{
                UIViewController * vc = [[RUChannelManager sharedInstance] viewControllerForChannel:child[@"channel"]];
                [self.navigationController pushViewController:vc animated:YES];
            };
        }
        [section addRow:row];
    }
    [self addSection:section];
}
-(void)fetchData{
    [[RUNetworkManager jsonSessionManager] GET:self.url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            self.children = responseObject[@"children"];
            [self makeSection];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self fetchData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self fetchData];
    }];
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

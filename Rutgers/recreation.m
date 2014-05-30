//
//  recreation.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "recreation.h"
#import "RUNetworkManager.h"
#import "RURecCenterViewController.h"
#import "EZTableViewSection.h"
#import "EZTableViewRow.h"

@interface recreation ()
@property NSDictionary *data;
@end

@implementation recreation
+(instancetype)component{
    return [[recreation alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [[RUNetworkManager jsonSessionManager] GET:@"gyms.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self parseResponse:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
-(void)parseResponse:(id)responseObject{
    self.data = responseObject;
    NSArray *campuses = [responseObject allKeys];
    campuses = [campuses sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSString *campus in campuses) {
        EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:campus];
        
        NSArray *recCenters = [[self.data[campus] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for (NSString *recCenter in recCenters) {

            EZTableViewRow *row = [[EZTableViewRow alloc] initWithText:recCenter];
            row.didSelectRowBlock = ^(){
                RURecCenterViewController *recVC = [[RURecCenterViewController alloc] initWithTitle:responseObject recCenter:self.data[campus][recCenter]];
                [self.navigationController pushViewController:recVC animated:YES];
            };
            [section addRow:row];
            
        }
        
        [self addSection:section];
    }
    
    [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, campuses.count)] withRowAnimation:UITableViewRowAnimationFade];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

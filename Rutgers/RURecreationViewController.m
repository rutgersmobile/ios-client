//
//  recreation.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecreationViewController.h"
#import "RUNetworkManager.h"
#import "RURecCenterViewController.h"
#import "EZDataSource.h"
#import "EZTableViewRightDetailRow.h"

@interface RURecreationViewController ()
@property (nonatomic) NSDictionary *recData;
@end

@implementation RURecreationViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RURecreationViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupContentLoadingStateMachine];
}

-(void)loadNetworkData{
    [[RUNetworkManager jsonSessionManager] GET:@"gyms.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.contentLoadingStateMachine networkLoadSuccessful];
        [self parseResponse:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.contentLoadingStateMachine networkLoadFailedWithNoData];
    }];
}

-(void)parseResponse:(id)responseObject{
    self.recData = responseObject;
    NSArray *campuses = [responseObject allKeys];
    campuses = [campuses sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [self.tableView beginUpdates];
    
    [self.dataSource removeAllSections];
    
    for (NSString *campus in campuses) {
        EZDataSourceSection *section = [[EZDataSourceSection alloc] initWithSectionTitle:campus];
        
        NSArray *recCenters = [[self.recData[campus] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for (NSString *recCenter in recCenters) {

            EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:recCenter];
            row.didSelectRowBlock = ^(){
                RURecCenterViewController *recVC = [[RURecCenterViewController alloc] initWithTitle:recCenter recCenter:self.recData[campus][recCenter]];
                [self.navigationController pushViewController:recVC animated:YES];
            };
            [section addItem:row];
        }
        [self.dataSource addSection:section];
    }
    [self.tableView endUpdates];
}

@end

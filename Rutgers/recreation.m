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
#import "EZTableViewRightDetailRow.h"

@interface recreation ()
@property (nonatomic) NSDictionary *recData;
@end

@implementation recreation
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[recreation alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startNetworkLoad];
}

-(void)startNetworkLoad{
    [super startNetworkLoad];
    [[RUNetworkManager jsonSessionManager] GET:@"gyms.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self parseResponse:responseObject];
        [self networkLoadSucceeded];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self networkLoadFailed];
    }];
}

-(void)parseResponse:(id)responseObject{
    self.recData = responseObject;
    NSArray *campuses = [responseObject allKeys];
    campuses = [campuses sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [self.tableView beginUpdates];
    for (NSString *campus in campuses) {
        EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:campus];
        
        NSArray *recCenters = [[self.recData[campus] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for (NSString *recCenter in recCenters) {

            EZTableViewRightDetailRow *row = [[EZTableViewRightDetailRow alloc] initWithText:recCenter];
            row.didSelectRowBlock = ^(){
                RURecCenterViewController *recVC = [[RURecCenterViewController alloc] initWithTitle:recCenter recCenter:self.recData[campus][recCenter]];
                [self.navigationController pushViewController:recVC animated:YES];
            };
            [section addRow:row];
        }
        [self addSection:section];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.sections.count-1] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

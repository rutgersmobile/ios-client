//
//  RURecCenterDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecCenterDataSource.h"
#import "RUNetworkManager.h"
#import "BasicDataSource.h"
#import "DataTuple.h"
#import "ALTableViewTextCell.h"
#import "TupleDataSource.h"

@implementation RURecCenterDataSource
-(void)loadContent{
    [[RUNetworkManager jsonSessionManager] GET:@"gyms.txt" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self parseResponse:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(void)parseResponse:(id)responseObject{
    NSArray *campuses = [responseObject allKeys];
    campuses = [campuses sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSString *campus in campuses) {
        TupleDataSource *recCenterDataForCampus = [[TupleDataSource alloc] init];
        recCenterDataForCampus.title = campus;
        
        NSArray *sortedKeys = [[responseObject[campus] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSMutableArray *recCenters  = [NSMutableArray array];
        for (NSString *key in sortedKeys) {
            [recCenters addObject:[DataTuple tupleWithTitle:key object:responseObject[campus][key]]];
        }
        
        recCenterDataForCampus.items = recCenters;
        
        [self addDataSource:recCenterDataForCampus];
    }
}
@end

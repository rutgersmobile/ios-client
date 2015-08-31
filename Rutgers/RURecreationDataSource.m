//
//  RURecCenterDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/24/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RURecreationDataSource.h"
#import "BasicDataSource.h"
#import "DataTuple.h"
#import "ALTableViewTextCell.h"
#import "TupleDataSource.h"
#import "DataSource_Private.h"

@implementation RURecreationDataSource
-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        NSString *url = @"gyms.txt";
        if (BETA) {
            url = @"gyms_array.txt";
        }
        
        [[RUNetworkManager sessionManager] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            if ([responseObject isKindOfClass:[NSArray class]]) {
                [loading updateWithContent:^(typeof(self) me) {
                    [me parseResponse:responseObject];
                }];
            } else {
                [loading updateWithContent:^(typeof(self) me) {
                    [me parseResponse:nil];
                }];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (!loading.current) {
                [loading ignore];
                return;
            }
            
            [loading doneWithError:error];
        }];
    }];
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(void)parseResponse:(id)responseObject{
    if (!BETA) return;
    
    NSArray *campuses = responseObject;
    for (NSDictionary *campus in campuses) {
        
        TupleDataSource *recCenterDataForCampus = [[TupleDataSource alloc] init];
        recCenterDataForCampus.title = campus[@"title"];
        
        NSMutableArray *recCenters  = [NSMutableArray array];
        for (NSDictionary *facility in campus[@"facilities"]) {
            [recCenters addObject:[DataTuple tupleWithTitle:facility[@"title"] object:facility]];
        }
        
        recCenterDataForCampus.items = recCenters;
        [self addDataSource:recCenterDataForCampus];
    }
}

@end

//
//  RUReaderDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderDataSource.h"
#import "RUReaderTableViewCell.h"
#import "RUNetworkManager.h"
#import "EZDataSource.h"
#import "RUReaderTableViewRow.h"
#import <UIKit+AFNetworking.h>


@interface RUReaderDataSource ()
@property NSString *url;
@end

@implementation RUReaderDataSource
-(id)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}


-(void)loadContent{
    [self loadContentWithBlock:^(AAPLLoading *loading) {
        [[RUNetworkManager xmlSessionManager] GET:self.url parameters:0 success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *channel = [responseObject[@"channel"] firstObject];
                [loading updateWithContent:^(typeof(self) me) {
                    [me parseResponse:channel[@"item"]];
                }];
            } else {
                [loading doneWithError:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [loading doneWithError:error];
        }];
    }];
}

-(void)parseResponse:(NSArray *)response{
    NSMutableArray *parsedItems = [NSMutableArray array];
    for (NSDictionary *item in response) {
        RUReaderTableViewRow *row = [[RUReaderTableViewRow alloc] initWithItem:item];
        [parsedItems addObject:row];
    }
    self.items = parsedItems;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[RUReaderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RUReaderTableViewCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([RUReaderTableViewCell class]);
}

-(void)configureCell:(RUReaderTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RUReaderTableViewRow *row = [self itemAtIndexPath:indexPath];
    
    cell.titleLabel.text = row.title;
    cell.timeLabel.text = row.date;
    
    cell.hasImage = row.imageURL ? YES : NO;
    cell.imageDisplayView.backgroundColor = [UIColor lightGrayColor];
    
    cell.imageDisplayView.image = nil;
    [cell.imageDisplayView setImageWithURL:row.imageURL];

}


@end